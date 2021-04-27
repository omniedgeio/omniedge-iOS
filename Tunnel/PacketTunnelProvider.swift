//
//  PacketTunnelProvider.swift
//  Tunnel
//
//  Created by samuelsong on 2021/4/27.
//

import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let log = OSLog(subsystem: "Omniedge", category: "default")
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log(.fault, log: log, "Omniedge Starting tunnel, options: %{private}@", "\(String(describing: options))");
        let ipv4 = NEIPv4Settings(addresses: ["10.0.0.1"], subnetMasks: ["255.255.255.0"]);
        let setting = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8");
        setting.mtu = 1500;
        setting.ipv4Settings = ipv4;
        setTunnelNetworkSettings(setting, completionHandler: {(_ error: Error?) -> Void in
            guard error == nil else {
                NSLog("error: \(String(describing: error))");
                completionHandler(error);
                return;
            }
            completionHandler(nil);
        });
        // Add code here to start the process of connecting the tunnel.
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
        os_log(.fault, log: log, "Omniedge stopTunnel tunnel, options: %{private}@");

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
}
