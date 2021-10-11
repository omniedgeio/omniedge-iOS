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

    init(scope: Scope) {
        self.scope = scope
    }

    func contentView() -> some View {
        let login = scope.getService(LoginAPI.self)
        let coordinator = login.createLoginCoordinator()
        return coordinator.createLoginView()
    }

    func bootstrap(scope: Scope) {
        scope.registerService(LoginAPI.self, Login.init)
    }
}
