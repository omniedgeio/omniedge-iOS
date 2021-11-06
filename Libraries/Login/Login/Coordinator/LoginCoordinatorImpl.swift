//
//  LoginCoordinatorImpl.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/20.
//  
//

import Foundation
import OEPlatform
import SwiftUI
import Tattoo

class LoginCoordinatorImpl: LoginCoordinator, LoginDelegate {
    private let scope: Scope
    private let router: RoutingAPI

    init(scope: Scope, router: RoutingAPI) {
        self.scope = scope
        self.router = router
    }

    func createLoginView() -> AnyView {
        let viewModel = LoginViewModel(LoginDataStoreProvider())
        viewModel.delegate = self
        return AnyView(LoginView(viewModel: viewModel))
    }

    func didLogin(_ viewModel: LoginViewModel?, token: String, uuid: String) {
        let session = scope.getService(SessionAPI.self)
        if session.login(token: token, uuid: uuid) {
            if let user = session.user {
                let deviceList = scope.getService(DeviceListAPI.self)
                let coordinator = deviceList.createHomeCoordinator(router: router, user: user)
                router.push(view: AnyView(coordinator.createHomePage().navigationBarHidden(true)))
                return
            }
        }

        if let viewModel = viewModel {
            viewModel.error = AuthError.fail(message: "Invalid token")
        }
    }

    func didRegister(_ viewModel: LoginViewModel?, email: String, password: String) {
    }

    func didReset(_ viewModel: LoginViewModel?, email: String) {
    }
}
