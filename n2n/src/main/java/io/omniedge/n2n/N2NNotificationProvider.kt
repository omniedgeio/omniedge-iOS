package io.omniedge.n2n

import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import com.blankj.utilcode.util.Utils

interface N2NNotificationProvider {
    companion object {
        const val NAME = "N2NNotificationProvider"

        @JvmStatic
         val notificationManager: NotificationManager
            get() = Utils.getApp().getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        const val notificationId = 1
    }

    fun removeNotification() {
        notificationManager.cancel(notificationId);
    }

    fun addNotification(context: Context)

    fun updateNotification(context: Context)
}
