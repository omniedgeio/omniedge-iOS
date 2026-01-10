//
//  OmniEdgeUDP.swift
//  Tunnel
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/18.
//  
//

import Foundation
import NetworkExtension
import os

class OmniEdgeUDP {
    private let logger = Logger(subsystem: "com.omniedge.client", category: "UDP")
    private let queue: DispatchQueue
    private var map: [String:(udp: NWUDPSession, observer: NSKeyValueObservation)]
    private let tunnel: NEPacketTunnelProvider

    init (queue: DispatchQueue, tunnel: NEPacketTunnelProvider) {
        self.queue = queue
        self.tunnel = tunnel
        map = [:]
    }

    // MARK: - Public
    public func sendData(data: Data, hostname: String, port: String, reader: @escaping ([Data]?, Error?) -> Void) {
        let key = hostname + port
        if let session = map[key] {
            session.udp.writeDatagram(data) { [weak self] error in
                if let error = error {
                    self?.logger.error("udp error: \(error, privacy: .public)")
                } else {
                    self?.logger.debug("udp ok")
                }
            }
        } else {
            let endpoint = NWHostEndpoint(hostname: hostname, port: port)
            let session = tunnel.createUDPSession(to: endpoint, from: nil)
            let observer = session.observe(\.state, options: [.new]) { [weak self] session, _ in
                guard let self = self else { return }
                self.logger.info("engine Session did update state: \(String(describing: session.state), privacy: .public)")
                self.queue.async {
                    self.handleSessionState(session, didUpdateState: session.state, data: data, addr: (ip: hostname, port: port), reader: reader)
                }
            }
            map[key] = (udp: session, observer: observer)
        }
    }

    // MARK: - Private
    private func handleSessionState(_ session: NWUDPSession, didUpdateState state: NWUDPSessionState, data: Data,
                                    addr: (ip: String, port: String), reader: @escaping ([Data]?, Error?) -> Void) {
        print("state: \(state)")
        switch state {
        case .ready:
            session.setReadHandler(reader, maxDatagrams: Int.max)
            session.writeDatagram(data) { [weak self] error in
                if let error = error {
                    self?.logger.error("udp error: \(error, privacy: .public)")
                } else {
                    self?.logger.debug("udp ok")
                }
            }
        case .failed:
            NSLog("UDP failed")
        default:
            break
        }
    }
}
