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
}

class PacketTunnelEngine {
    // MARK: - Property
    private var n2n_queue: UnsafeMutableRawPointer?;
    private let queue = DispatchQueue(label: "omniedge.packet-tunnel-provider"); //serial
    
    // MARK: - Init and Deinit
    init() {
        n2n_queue = n2n_create_event_queue();
    }
    deinit {
        if let queue = n2n_queue {
            n2n_destroy_event_queue(queue);
        }
    }

    //MARK: - Public
    func start() {
        var status: n2n_edge_status_t = n2n_edge_status_t();
        status.event_queue = n2n_queue;
        queue.async {
            start_edge_v2(&status);
        }
    }
    func stop() {
        queue.async {
            stop_edge_v2();
        }
    }
    func sendEvent(event: Event, data: Data?) {
        queue.async {
            n2n_event_send(self.n2n_queue, N2N_EVENT_TUN, nil, 0);
        }
    }
    
    //MARK: - Private
}
