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
    private let n2nQueue = DispatchQueue(label: "omniedge.n2n"); //serial
    private var pendingCompletion: ((Error?) -> Void)?
    private weak var timeoutTimer: Timer?
    private var observer: AnyObject?

    // MARK: - Init and Deinit
    init(provider: PacketTunnelProvider) {
        super.init();
        tunnel = provider;
        ocEngine = EdgeEngine.init(tunnelProvider: self);
    }

    //MARK: - Public
    func start(config: OmniEdgeConfig, _ completionHandler: @escaping (Error?) -> Void) {
        pendingCompletion = completionHandler;
        self.startTunnel();
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
                    engine.onData(data, with: NetDataType.tun, ip: "", port: 0);
                }
            }
        }
    }
    
    //MARK: - Called By N2N
    @objc
    func writeTunData(_ data: Data?) {
        guard let data = data else {
            return;
        }
        queue.async { [weak self] in
            self?.tunnel.packetFlow.writePackets([data], withProtocols: [AF_INET as NSNumber]);
        }
    }
    @objc
    func sendUdp(data: Data?, hostname: String, port: String) -> Bool {
        guard let data = data else {
            return false;
        }
        os_log(.default, log: self.log, "send udp data: \(data.count), \((String(describing: hostname))), \(String(describing: port))")

        if udpSession == nil {
            os_log(.default, log:self.log, "+++ create udp session");
            
            let endpoint = NWHostEndpoint(hostname: hostname, port: port)
            udpSession = tunnel.createUDPSession(to: endpoint, from: nil)
            udpSession.setReadHandler({ [weak self] datagrams, error in
                os_log(.default, log: self!.log, "--------udp recv data")
                guard let self = self else { return }
                os_log(.default, log: self.log, "udp recv data")
                self.queue.async {
                    if let engine = self.ocEngine, let list = datagrams {
                        for item in list {
                            engine.onData(item, with: NetDataType.udp, ip: hostname, port: Int(port) ?? 0);
                        }
                    }
                }
            }, maxDatagrams: Int.max);
        }
        
        udpSession.writeDatagram(data) { error in
            if let error = error {
                // TODO: Handle errors
                os_log(.default, log: self.log, "Failed to write udp datagram, error: %{public}@", "\(error)")
            } else {
                os_log(.default, log: self.log, "Success to write udp datagram:\(data.count)")
            }
        }

        return false;
    }

    //MARK: - Private
    private func startTunnel() {
        os_log(.default, log: self.log, "engine startTunnel");
        self.startUDPSession()

        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            os_log(.default, log: self.log, "engine startTunnel timeout");
            self.pendingCompletion?(NEVPNError(.connectionFailed))
            self.pendingCompletion = nil
        }
    }
    
    private func startUDPSession() {
        os_log(.default, log: log, "engine Starting UDP session");
        //let endpoint = NWHostEndpoint(hostname: "151.11.50.180", port: "7777");
        let endpoint = NWHostEndpoint(hostname: "54.223.23.92", port: "7787");
        self.udpSession = tunnel.createUDPSession(to: endpoint, from: nil)
        self.observer = udpSession.observe(\.state, options: [.new]) { [weak self] session, _ in
            guard let self = self else { return }
            os_log(.default, log: self.log, "engine Session did update state: %{public}@", session)
            self.queue.async {
                self.udpSession(session, didUpdateState: session.state, ip:"54.223.23.92", port:7787);
            }
        }
    }
    
    private func udpSession(_ session: NWUDPSession, didUpdateState state: NWUDPSessionState, ip: String, port: Int) {
        switch state {
        case .ready:
            guard pendingCompletion != nil else { return }
            session.setReadHandler({ [weak self] datagrams, error in
                guard let self = self else { return }
                self.queue.async {
                    if let engine = self.ocEngine, let list = datagrams {
                        for item in list {
                            engine.onData(item, with: NetDataType.udp, ip: ip, port: port);
                        }
                    }
                }
            }, maxDatagrams: Int.max)
            self.timeoutTimer?.invalidate()
            pendingCompletion?(nil);
            pendingCompletion = nil;
            n2nQueue.async { [weak self] in
                self?.ocEngine.start();
            };

        case .failed:
            guard pendingCompletion != nil else { return }
            pendingCompletion?(NEVPNError(.connectionFailed))
            pendingCompletion = nil
        default:
            break
        }
    }
    
    private func didReceiveDatagrams(datagrams: [Data], error: Error?, ip: String, port: Int) {
        for datagram in datagrams {
            do {
                os_log(.default, log: self.log, "UDP session read handler error: %{public}@", "\(datagrams)")
                //try self.didReceiveDatagram(datagram: datagram)
            } catch {
                // TODO: handle error
                os_log(.default, log: self.log, "UDP session read handler error: %{public}@", "\(error)")
            }
        }
        if let error = error {
            // TODO: handle error
            os_log(.default, log: self.log, "UDP session read handler error: %{public}@", "\(error)")
        }
    }

}
