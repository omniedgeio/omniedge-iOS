package io.omniedge.n2n;

import android.content.Intent;
import android.net.VpnService;
import android.os.Bundle;
import android.os.Handler;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import android.widget.Toast;

import java.io.IOException;

import io.omniedge.ProviderManager;
import io.omniedge.RxBus;
import io.omniedge.n2n.event.ErrorEvent;
import io.omniedge.n2n.event.StartEvent;
import io.omniedge.n2n.event.StopEvent;
import io.omniedge.n2n.event.SupernodeDisconnectEvent;
import io.omniedge.n2n.model.EdgeCmd;
import io.omniedge.n2n.model.EdgeStatus;
import io.omniedge.n2n.model.N2NSettingInfo;

import static io.omniedge.n2n.N2nTools.getIpAddrPrefixLength;
import static io.omniedge.n2n.N2nTools.getRoute;
import static io.omniedge.n2n.model.EdgeStatus.RunningStatus.DISCONNECT;
import static io.omniedge.n2n.model.EdgeStatus.RunningStatus.SUPERNODE_DISCONNECT;


public class N2NService extends VpnService {

    public static N2NService INSTANCE;

    private ParcelFileDescriptor mParcelFileDescriptor = null;
    private EdgeCmd cmd;

    private EdgeStatus.RunningStatus mLastStatus = DISCONNECT;
    private EdgeStatus.RunningStatus mCurrentStatus = DISCONNECT;

    private boolean mStopInProgress = false;

    @Override
    public void onCreate() {
        super.onCreate();
        INSTANCE = this;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) {
            RxBus.Companion.getINSTANCE().post(new ErrorEvent());
            return super.onStartCommand(intent, flags, startId);
        }

        Bundle setting = intent.getBundleExtra("Setting");
        N2NSettingInfo n2nSettingInfo = setting.getParcelable("n2nSettingInfo");

        Builder builder = new Builder()
                .setMtu(n2nSettingInfo.getMtu())
                .addAddress(n2nSettingInfo.getIp(), getIpAddrPrefixLength(n2nSettingInfo.getNetmask()))
                .addRoute(getRoute(n2nSettingInfo.getIp(), getIpAddrPrefixLength(n2nSettingInfo.getNetmask())), getIpAddrPrefixLength(n2nSettingInfo.getNetmask()));

        if (!n2nSettingInfo.getGatewayIp().isEmpty()) {
            /* Route all the internet traffic via n2n. Most specific routes "win" over the system default gateway.
             * See https://github.com/zerotier/ZeroTierOne/issues/178#issuecomment-204599227 */
            builder.addRoute("0.0.0.0", 1);
            builder.addRoute("128.0.0.0", 1);
        }

        if (!n2nSettingInfo.getDnsServer().isEmpty()) {
            Log.d("N2NService", "Using DNS server: " + n2nSettingInfo.getDnsServer());
            builder.addDnsServer(n2nSettingInfo.getDnsServer());
        }

        String session = getResources().getStringArray(R.array.vpn_session_name)[n2nSettingInfo.getVersion()];
        try {
            mParcelFileDescriptor = builder.setSession(session).establish();
        } catch (IllegalArgumentException e) {
            Toast.makeText(INSTANCE, "Parameter is not accepted by the operating system.", Toast.LENGTH_SHORT).show();
            return super.onStartCommand(intent, flags, startId);
        } catch (IllegalStateException e) {
            Toast.makeText(INSTANCE, "Parameter cannot be applied by the operating system.", Toast.LENGTH_SHORT).show();
            return super.onStartCommand(intent, flags, startId);
        }

        if (mParcelFileDescriptor == null) {
            RxBus.Companion.getINSTANCE().post(new ErrorEvent());
            return super.onStartCommand(intent, flags, startId);
        }

        cmd = new EdgeCmd(n2nSettingInfo, mParcelFileDescriptor.detachFd(), getExternalFilesDir("log") + "/" + session + ".log");
        try {
            if (!startEdge(cmd)) {
                RxBus.Companion.getINSTANCE().post(new ErrorEvent());
            }
        } catch (Exception e) {
            RxBus.Companion.getINSTANCE().post(new ErrorEvent());
        }

        return super.onStartCommand(intent, flags, startId);
    }

    public boolean isStopInProgress() {
        return (mStopInProgress);
    }

    public boolean stop(final Runnable onStopCallback) {
        if (isStopInProgress()) {
            Toast.makeText(getApplicationContext(), "a stop command is already in progress", Toast.LENGTH_SHORT).show();
            return (false);
        }

        /* Using a separate thread to avoid blocking the main thread
         * as stopEdge calls pthread_join on the n2n status thread which
         * can take some time to finish (e.g. for calls to getaddrinfo) */
        Thread stopThread = new Thread(new Runnable() {
            @Override
            public void run() {
                /* Blocking call */
                stopEdge();

                Handler handler = new Handler(getMainLooper());
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        mLastStatus = mCurrentStatus = DISCONNECT;
                        showOrRemoveNotification(CMD_REMOVE_NOTIFICATION);

                        try {
                            if (mParcelFileDescriptor != null) {
                                mParcelFileDescriptor.close();
                                mParcelFileDescriptor = null;
                            }
                        } catch (IOException e) {
                            RxBus.Companion.getINSTANCE().post(new ErrorEvent());
                            return;
                        }

                        RxBus.Companion.getINSTANCE().post(new StopEvent());
                        mStopInProgress = false;

                        if (onStopCallback != null)
                            onStopCallback.run();
                    }
                });
            }
        });

        mStopInProgress = true;
        stopThread.start();
        return (true);
    }

    @Override
    public void onRevoke() {
        super.onRevoke();
        stop(null);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stop(null);
    }

    public native boolean startEdge(EdgeCmd cmd);

    public native void stopEdge();

    public void reportEdgeStatus(EdgeStatus status) {
        mLastStatus = mCurrentStatus;
        mCurrentStatus = status.runningStatus;

        if (mLastStatus == mCurrentStatus) {
            return;
        }

        switch (status.runningStatus) {
            case CONNECTING:
            case CONNECTED:
                RxBus.Companion.getINSTANCE().post(new StartEvent());
                if (mLastStatus == SUPERNODE_DISCONNECT) {
                    showOrRemoveNotification(CMD_UPDATE_NOTIFICATION);
                }
                break;
            case SUPERNODE_DISCONNECT:
                showOrRemoveNotification(CMD_ADD_NOTIFICATION);
                RxBus.Companion.getINSTANCE().post(new SupernodeDisconnectEvent());
                break;
            case DISCONNECT:
            case FAILED:
                RxBus.Companion.getINSTANCE().post(new StopEvent());
                if (mLastStatus == SUPERNODE_DISCONNECT) {
                    showOrRemoveNotification(CMD_REMOVE_NOTIFICATION);
                }
                break;
            default:
                break;
        }
    }

    public EdgeStatus.RunningStatus getCurrentStatus() {
        return mCurrentStatus;
    }

    private static final int CMD_REMOVE_NOTIFICATION = 0;
    private static final int CMD_ADD_NOTIFICATION = 1;
    private static final int CMD_UPDATE_NOTIFICATION = 2;

    //supernode连接断开 supernode连接恢复 连接断开/失败--清除通知栏
    private void showOrRemoveNotification(int cmd) {
        // TODO: 2020/12/6 abstraction
        N2NNotificationProvider provider =
                ProviderManager.INSTANCE.getProvider(N2NNotificationProvider.NAME);
        switch (cmd) {
            case CMD_REMOVE_NOTIFICATION:
                provider.removeNotification();
                break;
            case CMD_ADD_NOTIFICATION:
                provider.addNotification(this);
                break;
            case CMD_UPDATE_NOTIFICATION:
                provider.updateNotification(this);
                break;
            default:
                break;
        }
    }
}
