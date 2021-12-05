//
//  DeviceListCoordinatorImpl.swift
//  DeviceList
//
//  Created by samuelsong on 2021/10/31.
//

import OEPlatform
import SwiftUI
import Tattoo

class DeviceListCoordinatorImpl: DeviceListCoordinator {
    private let scope: Scope
    private let router: RoutingAPI
    private var user: User
    private let token: String

    init(scope: Scope, router: RoutingAPI, user: User, token: String) {
        self.scope = scope
        self.router = router
        self.user = user
        self.token = token
    }

    func createHomePage() -> AnyView {
        let viewModel = DeviceListViewModel(dataStore: DeviceListDataProvider(), token: token, user: user)
        viewModel.delegate = self
        return AnyView(DeviceListView(viewModel: viewModel))
    }
}

extension DeviceListCoordinatorImpl: DeviceListDelegate {
    func start() {
        let tunnel = scope.getService(TunnelAPI.self)
        tunnel.start()
    }

    func stop() {
        let tunnel = scope.getService(TunnelAPI.self)
        tunnel.stop()
    }
    
    func didLoadNetworkList(_ viewModel: DeviceListViewModel?, list: [String]) {
        guard user.network == nil else {
            return
        }
        
        if let network = list.first {
            viewModel?.joinNetwork(request: JoinRequest(uuid: network, deviceID: user.deviceUUID ?? "", token: token))
        }
    }

    func didJoinNetwork(_ uuid: String, model: N2NModel) -> Bool {
        let config = scope.getService(ConfigAPI.self)
        let address = model.server.host.components(separatedBy: ":")
        if address.count > 1 {
            if let hostIP = getIPs(dnsName: address[0]) {
                /// save config
                let n2nConfig = N2NConfig(host: hostIP, port: address[1], networkName: model.community_name, ip: model.virtual_ip, key: model.secret_key)
                config.save(config: n2nConfig)

                /// save user info
                let userManager = scope.getService(UserAPI.self)
                let info = OENetworkInfo(networkUUID: uuid, ip: model.virtual_ip)
                user.network = info
                userManager.setUser(user, for: user.email)

                return true
            }
        }
        return false
    }

    // You many want to run this in the background
    private func getIPs(dnsName: String) -> String? {
        let host = CFHostCreateWithName(nil, dnsName as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            for case let theAddress as NSData in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    return numAddress
                }
            }
        }

        return nil
    }

    func showSetting() {
        let viewModel = SettingViewModel()
        viewModel.delegate = self
        let view = SettingView(viewModel: viewModel)
        router.push(view: AnyView(view))
    }
}

extension DeviceListCoordinatorImpl: SettingDelegate {
    func logout() {
        let session = scope.getService(SessionAPI.self)
        session.logout()
        let loginAPI = scope.getService(LoginAPI.self)
        let navigator = SHNavigationView(scope: scope) { router -> AnyView in
            let coordinator = loginAPI.createLoginCoordinator(router: router)
            return coordinator.createLoginView()
        }
        router.push(view: AnyView(navigator.ignoresSafeArea()), parameters: RoutingParameters(allowDismiss: false))
    }
}
