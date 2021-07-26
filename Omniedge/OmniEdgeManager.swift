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
        
        public var text: String {
            switch self {
            case .on:
                return "On"
            case .connecting:
                return "Connecting..."
            case .disconnecting:
                return "Disconnecting..."
            case .off, .invalid:
                return "Off"
            }
        }
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
    
    public private(set) var tunnel: NETunnelProviderManager?
    public var isOn: Bool { status == .on }
    public private(set) var status: Status = .off {
        didSet { notifyStatusDidChange() }
    }

    private var observers = [AnyObject]()

    private init() {
        refresh()
        observers.append(
            NotificationCenter.default.addObserver(
                forName: .NEVPNStatusDidChange,
                object: nil,
                queue: OperationQueue.main
            ) { [weak self] _ in
                self?.updateStatus()
            }
        )

        observers.append(
            NotificationCenter.default.addObserver(
                forName: .NEVPNConfigurationChange,
                object: nil,
                queue: OperationQueue.main
            ) { [weak self] _ in
                self?.refresh()
            }
        )
    }
}

extension OmniEdgeManager {
    func start(with config: OmniEdgeConfig,
               completion: @escaping Handler) {
        loadTunnelManager { [unowned self] manager, error in
            if let error = error {
                return completion(error)
            }

            if manager == nil {
                self.tunnel = self.makeTunnelManager(with: config)
            }

            self.saveToPreferences(with: config) { [weak self] error in
                if let error = error {
                    return completion(error)
                }

                self?.tunnel?.loadFromPreferences() { [weak self] _ in
                    self?.start(completion)
                }
            }
        }
    }

    func start(_ completion: @escaping Handler) {
        do {
            try tunnel?.connection.startVPNTunnel()
        } catch {
            completion(error)
        }
    }

    func stop() {
        tunnel?.connection.stopVPNTunnel()
    }

    func refresh(completion: Handler? = nil) {
        loadTunnelManager { [weak self] _, error in
            self?.updateStatus()
            completion?(error)
        }
    }

    func setEnabled(_ isEnabled: Bool, completion: @escaping Handler) {
        guard isEnabled != tunnel?.isEnabled else { return }
        tunnel?.isEnabled = isEnabled
        saveToPreferences(completion: completion)
    }

    func saveToPreferences(with config: OmniEdgeConfig? = nil,
                           completion: @escaping Handler) {
        if let config = config {
            config.sync()
            tunnel?.config(with: config)
        }
        tunnel?.saveToPreferences { error in
            completion(error)
        }
    }

    func removeFromPreferences(completion: @escaping Handler) {
        tunnel?.removeFromPreferences { [weak self] error in
            if error != nil {
                self?.tunnel = nil
            }
            completion(error)
        }
    }
}

extension OmniEdgeManager {
    func loadTunnelManager(_ complition: @escaping (NETunnelProviderManager?, Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [unowned self] managers, error in
            self.tunnel = managers?.first
            complition(managers?.first, error)
        }
    }

    func makeTunnelManager(with config: OmniEdgeConfig) -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let proto = NETunnelProviderProtocol();
        // WARNING: This must match the bundle identifier of the app extension
        // containing packet tunnel provider.
        proto.providerBundleIdentifier = "com.meandlife.Omniedge.Tunnel";
        proto.serverAddress = "Omniedge";//supernode.ntop.org:7777";
        /// passwordReference必须取keychain里面的值
        proto.providerConfiguration = [:];
        manager.protocolConfiguration = proto;
        manager.localizedDescription = "Omniedge"
        manager.isEnabled = true;

        return manager
    }

    func updateStatus() {
        if let tunnel = tunnel {
            status = Status(tunnel.connection.status)
        } else {
            status = .off
        }
    }

    func notifyStatusDidChange() {
        statusDidChangeHandler?(status)
    }
}

public extension NETunnelProviderManager {
    func config(with config: OmniEdgeConfig) {
        guard let proto = protocolConfiguration as? NETunnelProviderProtocol else {
            return
        }
        proto.serverAddress = "\(config.superNodeAddr):\(config.superNodePort)"
        protocolConfiguration = proto
    }
}
