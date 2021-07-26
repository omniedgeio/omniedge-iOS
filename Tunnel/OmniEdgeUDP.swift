//
//  OmniEdgeUDP.swift
//  Tunnel
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/18.
//  
//

import Foundation
import NetworkExtension
import os.log

class OmniEdgeUDP {
    private let log = OSLog(subsystem: "Omniedge", category: "udp");
    private let queue: DispatchQueue
    private var map: [String:(udp: NWUDPSession, observer: NSKeyValueObservation)];
    private let tunnel: NEPacketTunnelProvider;
    
    init (queue: DispatchQueue, tunnel: NEPacketTunnelProvider) {
        self.queue = queue;
        self.tunnel = tunnel;
        map = [:];
    }
    
    // MARK: - Public
    public func sendData(data: Data, hostname: String, port: String, reader: @escaping ([Data]?, Error?) -> Void) {
        let key = hostname + port;
        if let session = map[key] {
            session.udp.writeDatagram(data) { [weak self] error in
                if let error = error {
                    os_log(.default, log: self?.log ?? .default, "udp error: %{public}@", "\(error)")
                } else {
                    os_log(.default, log: self?.log ?? .default, "udp ok")
                }
            }
        } else {
            let endpoint = NWHostEndpoint(hostname: hostname, port: port)
            let session = tunnel.createUDPSession(to: endpoint, from: nil)
            let observer = session.observe(\.state, options: [.new]) { [weak self] session, _ in
                guard let self = self else { return }
                os_log(.default, log: self.log, "engine Session did update state: %{public}@", session)
                self.queue.async {
                    self.handleSessionState(session, didUpdateState: session.state, data:data,
                                            ip:hostname, port:port, reader: reader);
                }
            }
            map[key] = (udp: session, observer: observer);
        }
    }
    
    // MARK: - Private
    private func handleSessionState(_ session: NWUDPSession, didUpdateState state: NWUDPSessionState, data: Data,
                                    ip: String, port: String, reader: @escaping ([Data]?, Error?) -> Void) {
        print("state: \(state)");
        switch state {
        case .ready:
            session.setReadHandler(reader, maxDatagrams: Int.max)
            session.writeDatagram(data) { [weak self] error in
                if let error = error {
                    os_log(.default, log: self?.log ?? .default, "udp error: %{public}@", "\(error)")
                } else {
                    os_log(.default, log: self?.log ?? .default, "udp ok")
                }
            }
        case .failed:
            NSLog("UDP failed")
        default:
            break
        }
    }
}
