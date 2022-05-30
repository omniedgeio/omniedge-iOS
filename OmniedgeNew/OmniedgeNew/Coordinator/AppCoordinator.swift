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
    private var scope: APICenter
    private var child: [Coordinator] = []

    init(scope: APICenter) {
        self.scope = scope
    }

    lazy var contentView: AnyView = {
        let session = scope.getService(SessionAPI.self)
        let userManager = scope.getService(UserAPI.self)

        if UserDefaults.standard.bool(forKey: "UserConcent") == false {
            return loginView
        }
        
        if let token = session.token, let email = token.jwt?.email {
            if let user = userManager.user(email: email), let _ = user.deviceUUID {
                return homeView(user, token: token)
            } else {
                if let user = userManager.createUser(token: token), let _ = user.deviceUUID {
                    return homeView(user, token: token)
                }
            }
        }
        return loginView
    }()

    func bootstrap(scope: APICenter) {
        scope.setupPlatformUserDefaults()
        scope.setupPlatformRouting()
        scope.registerModule(SessionAPI.self, SessionManager.init)
        scope.registerModule(LoginAPI.self, Login.init)
        scope.registerModule(DeviceListAPI.self, DeviceList.init)
        scope.registerModule(UserAPI.self, UserManager.init)
        scope.registerModule(ConfigAPI.self, OmniEdgeConfigProvider.init)
        scope.registerModule(TunnelAPI.self, TunnelProvider.init)
    }

    private var loginView: AnyView {
        let loginAPI = scope.getService(LoginAPI.self)
        let navigator = SHNavigationView(scope: scope) { [weak self] router -> AnyView in
            let coordinator = loginAPI.createLoginCoordinator(router: router)
            self?.child.append(coordinator)
            return coordinator.createLoginView()
        }
        return AnyView(navigator.ignoresSafeArea().navigationBarHidden(true))
    }

    private func homeView(_ user: User, token: String) -> AnyView {
        let deviceList = scope.getService(DeviceListAPI.self)
        let navigator = SHNavigationView(scope: scope) { [weak self] router -> AnyView in
            let coordinator = deviceList.createHomeCoordinator(router: router, user: user, token: token)
            self?.child.append(coordinator)
            return coordinator.createHomePage()
        }
        return AnyView(navigator.ignoresSafeArea().navigationBarHidden(true))
    }
}
