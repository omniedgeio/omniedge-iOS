//
//  PacketTunnelEngine.swift
//  Omniedge
//
//  Created by samuelsong on 2021/5/26.
//

import Foundation

enum Event {
    case TunEvent
    case UDPEvent
    case MgrEvent
}

class PacketTunnelEngine {
    // MARK: - Property
    private var n2n_bridge: UnsafeMutableRawPointer?;
    private let queue = DispatchQueue(label: "omniedge.packet-tunnel-provider"); //serial
    
    // MARK: - Init and Deinit
    init() {
        n2n_bridge = ios_create_bridge();
    }
    deinit {
        if let bridge = n2n_bridge {
            ios_destroy_bridge(bridge);
        }
    }

    //MARK: - Public
    func start(config: OmniEdgeConfig) {
        queue.async {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
            let url: URL = path[0];
            ios_start_edge_v2(url.absoluteString, self.n2n_bridge);
        };
    }
    func stop() {
        queue.async {
            ios_stop_edge_v2();
        }
    }
    func sendEvent(event: Event, data: Data?) {
        if let data = data, data.count > 0 {
            queue.async {
                if let bridge = self.n2n_bridge {
                    switch event {
                    case .TunEvent:
                        data.withUnsafeBytes { rawBufferPointer in
                            let p = rawBufferPointer.baseAddress;
                            ios_receive_tun_data(bridge, p, Int32(data.count));
                        }
                    case .UDPEvent:
                        data.withUnsafeBytes { rawBufferPointer in
                            let p = rawBufferPointer.baseAddress;
                            ios_receive_udp_data(bridge, p, Int32(data.count));
                        }
                    case .MgrEvent:
                        data.withUnsafeBytes { rawBufferPointer in
                            let p = rawBufferPointer.baseAddress;
                            ios_receive_mgr_data(bridge, p, Int32(data.count));
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Private
}
