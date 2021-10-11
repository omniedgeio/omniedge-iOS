//
//  AppCoordinator.swift
//  OmniedgeNew
//
//  Created by samuelsong on 2021/10/11.
//

import OEPlatform
import OEUIKit
import SwiftUI
import Login
import Tattoo

class AppCoordinator: Coordinator {
    private var scope: Scope
    private var child: [Coordinator] = []

    init(scope: Scope) {
        self.scope = scope
    }

    lazy var contentView: AnyView = {
        let loginAPI = scope.getService(LoginAPI.self)
        let coordinator = loginAPI.createLoginCoordinator()
        self.child.append(coordinator)
        return coordinator.createLoginView()
    }()

    func bootstrap(scope: Scope) {
        scope.registerService(LoginAPI.self, Login.init)
    }
}
