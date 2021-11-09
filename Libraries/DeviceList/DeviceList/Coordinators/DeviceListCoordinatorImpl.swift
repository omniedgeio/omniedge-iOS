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

    init(scope: Scope, router: RoutingAPI, user: User) {
        self.scope = scope
        self.router = router
        self.user = user
    }

    func createHomePage() -> AnyView {
        let viewModel = DeviceListViewModel()
        viewModel.delegate = self
        return AnyView(DeviceListView(viewModel: viewModel))
    }
}

extension DeviceListCoordinatorImpl: DeviceListDelegate {
    func logout() {
        let session = scope.getService(SessionAPI.self)
        session.logout()
    }
}
