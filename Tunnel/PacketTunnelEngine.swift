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
    private var even_queue: UnsafeMutableRawPointer?
    
    // MARK: - Init and Deinit
    init() {
        even_queue = n2n_create_event_queue();
    }
    deinit {
        if let queue = even_queue {
            n2n_destroy_event_queue(queue);
        }
    }

    //MARK: - Public
    func start() {
        var status: n2n_edge_status_t = n2n_edge_status_t();
        status.event_queue = even_queue;
        start_edge_v2(&status);
    }
    func stop() {
        stop_edge_v2();
    }
    func sendEvent(event: Event, data: Data?) {
        n2n_event_send(even_queue, N2N_EVENT_TUN, nil, 0);
    }
    
    //MARK: - Private
}
