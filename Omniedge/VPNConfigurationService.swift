//
//  VPNConfigurationService.swift
//  Omniedge
//
//  Created by samuelsong on 2021/5/15.
//

import Foundation
import NetworkExtension
import UIKit

final class VPNConfigurationService: ObservableObject {
    // MARK: - Variable
    @Published private(set) var isStarted = false;
    static let shared = VPNConfigurationService();
    private var manager: NETunnelProviderManager?;
    private var observer: AnyObject?;
    // MARK: - Init
    private init() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                          object: nil, queue: .main) { [weak self] _ in
            self?.refresh();
        }
    }
    
    // MARK: - Public
    func stop() {
        do {
            try manager?.connection.stopVPNTunnel()
        } catch {
            print(error);
        }
    }
    
    func start() {
        do {
            try manager?.connection.startVPNTunnel(options: [:])
        } catch {
            print(error);
        }
    }
    func refresh(complete: @escaping (Result<Void, Error>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] list, error in
            guard let self = self else { return };
            if let error = error {
                complete(.failure(error));
            } else {
                if let list = list {
                    if list.count > 0 {
                        self.manager = list.first;
                        self.manager?.isEnabled = true;
                        self.isStarted = true;
                        complete(.success(()));
                    }
                }
            }
        }
    }
    func installProfile(_ complete: @escaping (Result<Void, Error>) -> Void) {
        let tunnel = makeManager();
        tunnel.saveToPreferences { [weak self] error in
            if let error = error {
                complete(.failure(error));
            }
            tunnel.loadFromPreferences { [weak self] error in
                self?.manager = tunnel;
                complete(.success(()));
            }
        }
    }
    // MARK: - Private
    private func refresh() {
        refresh {_ in };
    }
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager();
        manager.localizedDescription = "Omniedge";
        let proto = NETunnelProviderProtocol();
        // WARNING: This must match the bundle identifier of the app extension
        // containing packet tunnel provider.
        proto.providerBundleIdentifier = "com.meandlife.Omniedge.Tunnel";
        proto.serverAddress = "54.223.23.92:7787";//supernode.ntop.org:7777";
        proto.providerConfiguration = [:];
        manager.protocolConfiguration = proto;
        manager.isEnabled = true;
        return manager;
    }
}
