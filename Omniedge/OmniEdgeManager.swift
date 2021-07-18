//
//  OmniEdgeManager.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation
import NetworkExtension
import OmniedgeDylib

public extension OmniEdgeManager {
    enum Status: String {
        case on
        case off
        case invalid /// The VPN is not configured
        case connecting
        case disconnecting
        
        public init(_ status: NEVPNStatus) {
            switch status {
            case .connected:
                self = .on
            case .connecting, .reasserting:
                self = .connecting
            case .disconnecting:
                self = .disconnecting
            case .disconnected, .invalid:
                self = .off
            @unknown default:
                self = .off
            }
        }
    }
}

public final class OmniEdgeManager {
    public typealias Handler = (Error?) -> Void
    //MARK: - Property
    static let shared = OmniEdgeManager();
    
    //MARK: - Public
    public var statusDidChangeHandler: ((Status) -> Void)?
    func start(with config: OmniEdgeConfig,
               completion: @escaping Handler) {
    }
    func start(_ completion: @escaping Handler) {
    }

    func stop() {
    }
    
    func remove(completion: @escaping Handler) {
    }

}
