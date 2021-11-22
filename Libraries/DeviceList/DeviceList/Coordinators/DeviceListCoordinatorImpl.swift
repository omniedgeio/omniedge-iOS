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
        let viewModel = DeviceListViewModel(dataStore: DeviceListDataProvider(), token: token)
        viewModel.delegate = self
        return AnyView(DeviceListView(viewModel: viewModel))
    }
}

extension DeviceListCoordinatorImpl: DeviceListDelegate {
    func logout() {
        let session = scope.getService(SessionAPI.self)
        session.logout()
    }

    func didLoadNetworkList(_ viewModel: DeviceListViewModel?, list: [String]) {
        guard user.network == nil else {
            return
        }
        if let network = list.first {
            viewModel?.joinNetwork(request: JoinRequest(uuid: network, deviceID: user.deviceUUID ?? "", token: token))
        }
    }

    func didJoinNetwork(_ uuid: String, model: N2NModel) {
        let userManager = scope.getService(UserAPI.self)
        let info = OENetworkInfo(networkUUID: uuid, ip: model.virtual_ip)
        user.network = info
        userManager.setUser(user, for: user.email)
    }
}
