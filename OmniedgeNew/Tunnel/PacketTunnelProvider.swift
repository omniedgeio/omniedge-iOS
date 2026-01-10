//
//  PacketTunnelProvider.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/4/27.
//

import NetworkExtension
import OmniedgeDylib
import os

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.omniedge.client", category: "PacketTunnel")
    private var engine: PacketTunnelEngine?

    // MARK: - Override
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Omniedge Starting tunnel, options: \(String(describing: options), privacy: .private)")
        engine = PacketTunnelEngine(provider: self)
        guard let engine = engine else {
            return
        }

        let config = OmniEdgeConfig()
        engine.start(config: config) { [weak self] error in
            guard let self = self else {
                return
            }
            self.logger.info("Omniedge Did setup tunnel")
            let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: config.superNodeAddr)
            let ipV4 = NEIPv4Settings(addresses: [config.ipAddress], subnetMasks: [config.subnetMask])
            
            // Calculate network address for routing
            let addresses = config.ipAddress.components(separatedBy: ".")
            let masks = config.subnetMask.components(separatedBy: ".")
            if addresses.count == 4 && masks.count == 4 {
                var networkAddressParts = [String]()
                for i in 0..<4 {
                    if let addrPart = Int(addresses[i]), let maskPart = Int(masks[i]) {
                        networkAddressParts.append("\(addrPart & maskPart)")
                    }
                }
                let networkAddress = networkAddressParts.joined(separator: ".")
                let vnwRoute = NEIPv4Route(destinationAddress: networkAddress, subnetMask: config.subnetMask)
                ipV4.includedRoutes = [vnwRoute]
            }
            
            settings.ipv4Settings = ipV4

            #if false
            let dns = "8.8.8.8,8.4.4.4,1.1.1.1,114.114.114.114"
            let dnsSettings = NEDNSSettings(servers: dns.components(separatedBy: ","))
            /// overrides system DNS settings
            dnsSettings.matchDomains = [""]
            settings.dnsSettings = dnsSettings
            #endif

            self.setTunnelNetworkSettings(settings) { error in
                self.logger.info("Did setup tunnel settings: \(settings, privacy: .public), error: \(String(describing: error), privacy: .public)")

                completionHandler(error)
                self.didStartTunnel()
            }
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        if let engine = engine {
            engine.stop { [weak self] in
                completionHandler()
                guard let self = self else { return }
                self.logger.error("Omniedge stopTunnel tunnel")
            }
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
        logger.error("Omniedge ****** omniedge now working*********")
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
        logger.error("Omniedge ****** omniedge now sleep*********")
    }

    override func wake() {
        // Add code here to wake up.
        logger.error("Omniedge ****** omniedge now wake*********")
    }

    // MARK: - Private
    private func didStartTunnel() {
        readPackets()
    }

    private func readPackets () {
        logger.error("Omniedge start readPackets")
        packetFlow.readPacketObjects { [weak self] packets in
            guard let self = self else {
                return
            }
            self.logger.error("Omniedge readPackets ok")
            if let engine = self.engine {
                for item in packets {
                    engine.onTunData(item.data)
                }
            }
            self.logger.error("Omniedge get a packet")
            self.readPackets()
        }
    }
}
