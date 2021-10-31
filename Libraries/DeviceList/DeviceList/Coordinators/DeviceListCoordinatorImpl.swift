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

    init(scope: Scope, router: RoutingAPI) {
        self.scope = scope
        self.router = router
    }

    func createHomePage() -> AnyView {
        return AnyView(DeviceListView())
    }
}
