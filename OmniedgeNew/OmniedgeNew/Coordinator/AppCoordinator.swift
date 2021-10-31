//
//  AppCoordinator.swift
//  OmniedgeNew
//
//  Created by samuelsong on 2021/10/11.
//

import DeviceList
import Login
import OEPlatform
import OEUIKit
import SwiftUI
import Tattoo

class AppCoordinator: Coordinator {
    private var scope: Scope
    private var child: [Coordinator] = []

    init(scope: Scope) {
        self.scope = scope
    }

    lazy var contentView: AnyView = {
        let loginAPI = scope.getService(LoginAPI.self)
        let navigator = SHNavigationView(scope: scope) { [weak self] router -> AnyView in
            let coordinator = loginAPI.createLoginCoordinator(router: router)
            self?.child.append(coordinator)
            return coordinator.createLoginView()
        }
        return AnyView(navigator.ignoresSafeArea())
    }()

    func bootstrap(scope: Scope) {
        scope.setupPlatformRouting()
        scope.registerModule(LoginAPI.self, Login.init)
        scope.registerModule(DeviceListAPI.self, DeviceList.init)
    }
}
