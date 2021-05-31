//
//  PacketTunnelEngine.swift
//  Omniedge
//
//  Created by samuelsong on 2021/5/26.
//

import Foundation
import NetworkExtension
import os.log

class PacketTunnelEngine : NSObject {
    // MARK: - Property
    private var ocEngine: EdgeEngine!;
    private weak var tunnel: PacketTunnelProvider!;
    private var udpSession: NWUDPSession!
    private let log = OSLog(subsystem: "Omniedge", category: "default");
    private let queue = DispatchQueue(label: "omniedge.packet-tunnel-provider"); //serial
    
    // MARK: - Init and Deinit
    init(provider: PacketTunnelProvider) {
        tunnel = provider;
        ocEngine = EdgeEngine.init(tunnelProvider: provider);
    }

    //MARK: - Public
    func start(config: OmniEdgeConfig) {
        queue.async { [weak self] in
            self?.ocEngine.start();
        };
    }
    func stop() {
        queue.async { [weak self] in
            self?.ocEngine.stop();
        }
    }
    func onTunData(_ data: Data?) {
        if let data = data, data.count > 0 {
            queue.async { [weak self] in
                if let engine = self?.ocEngine {
                    engine.onData(data, with: NetDataType.tun);
                }
            }
        }
    }
    
    @objc
    func sendUdp(data: Data?, hostname: String, port: String) -> Bool {
        guard let data = data else {
            return false;
        }
        
        let endpoint = NWHostEndpoint(hostname: hostname, port: port)
        udpSession = tunnel.createUDPSession(to: endpoint, from: nil)
        udpSession.setReadHandler({ [weak self] datagrams, error in
            guard let self = self else { return }
            self.queue.async {
                //self.didReceiveDatagrams(datagrams: datagrams ?? [], error: error)
            }
        }, maxDatagrams: Int.max);
        
        udpSession.writeDatagram(data) { error in
            if let error = error {
                // TODO: Handle errors
                os_log(.default, log: self.log, "Failed to write auth request datagram, error: %{public}@", "\(error)")
            }
        }

        return false;
    }

    //MARK: - Private
}
