//
//  PacketTunnelProvider.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/4/27.
//

import NetworkExtension
import os.log
import OmniedgeDylib

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let log = OSLog(subsystem: "Omniedge", category: "default");
    private var engine: PacketTunnelEngine?
    
    // MARK: - Override
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log(.default, log: log, "Omniedge Starting tunnel, options: %{private}@", "\(String(describing: options))")
        
        if (engine == nil) {
            engine = PacketTunnelEngine.init(provider: self);
        }
        if let engine = engine {
            let config = OmniEdgeConfig();
            engine.start(config: config) { [weak self] error in
                guard let self = self else {
                    return;
                }
                os_log(.default, log: self.log, "Omniedge Did setup tunnel")
                //let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "151.11.50.180");
                //let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "54.223.23.92");
                let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: config.superNodeAddr);
                let ipV4 = NEIPv4Settings.init(addresses: [config.ipAddress], subnetMasks: ["255.255.255.0"]);
                ipV4.includedRoutes = [NEIPv4Route.default()];
                settings.ipv4Settings = ipV4;
                
                #if false
                let dns = "8.8.8.8,8.4.4.4"
                let dnsSettings = NEDNSSettings(servers: dns.components(separatedBy: ","))
                /// overrides system DNS settings
                dnsSettings.matchDomains = [""]
                settings.dnsSettings = dnsSettings
                #endif
                
                self.setTunnelNetworkSettings(settings) { error in
                    os_log(.default, log: self.log, "Did setup tunnel settings: %{public}@, error: %{public}@", "\(settings)", "\(String(describing: error))")

                    completionHandler(error)
                    self.didStartTunnel()
                }
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        if let e = engine {
            e.stop { [weak self] in
                completionHandler()
                guard let self = self else { return }
                os_log(.fault, log: self.log, "Omniedge stopTunnel tunnel, options: %{private}@");
            }
        }
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
        os_log(.fault, log: log, "Omniedge ****** omniedge now working*********\n");
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
        os_log(.fault, log: log, "Omniedge ****** omniedge now sleep*********\n");
    }
    
    override func wake() {
        // Add code here to wake up.
        os_log(.fault, log: log, "Omniedge ****** omniedge now wake*********\n");
    }
    
    // MARK: - Private
    private func didStartTunnel() {
        readPackets()
    }

    private func readPackets () {
        os_log(.fault, log: log, "Omniedge start readPackets\n");
        packetFlow.readPacketObjects { [weak self] packets in
            guard let self = self else {
                return;
            }
            os_log(.fault, log: self.log, "Omniedge readPackets ok\n");
            if let e = self.engine {
                for item in packets {
                    e.onTunData(item.data);
                }
            }
            os_log(.fault, log: self.log, "Omniedge get a packet\n");
            self.readPackets();
        }
    }
}
