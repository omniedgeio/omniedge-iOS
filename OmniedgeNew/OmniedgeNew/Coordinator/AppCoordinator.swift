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
        let session = scope.getService(SessionAPI.self)
        if let user = session.user {
            return homeView(user)
        } else {
            return loginView
        }
    }()

    func bootstrap(scope: Scope) {
        scope.setupPlatformRouting()
        scope.registerModule(SessionAPI.self, SessionManager.init)
        scope.registerModule(LoginAPI.self, Login.init)
        scope.registerModule(DeviceListAPI.self, DeviceList.init)
    }

    private var loginView: AnyView {
        let loginAPI = scope.getService(LoginAPI.self)
        let navigator = SHNavigationView(scope: scope) { [weak self] router -> AnyView in
            let coordinator = loginAPI.createLoginCoordinator(router: router)
            self?.child.append(coordinator)
            return coordinator.createLoginView()
        }
        return AnyView(navigator.ignoresSafeArea())
    }

    private func homeView(_ user: User) -> AnyView {
        let deviceList = scope.getService(DeviceListAPI.self)
        let navigator = SHNavigationView(scope: scope) { [weak self] router -> AnyView in
            let coordinator = deviceList.createHomeCoordinator(router: router, user: user)
            self?.child.append(coordinator)
            return coordinator.createHomePage()
        }
        return AnyView(navigator.ignoresSafeArea())
    }
}