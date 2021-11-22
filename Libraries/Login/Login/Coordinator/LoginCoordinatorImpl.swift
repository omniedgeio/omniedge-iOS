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

    func didLogin(_ viewModel: LoginViewModel?, token: String) {
        let session = scope.getService(SessionAPI.self)
        let userManager = scope.getService(UserAPI.self)
        var error = false

        if session.login(token: token) {
            if let email = session.email(token: token) {
                var currentUsr: User? = nil

                if let user = userManager.user(email: email) {
                    currentUsr = user
                } else {
                    currentUsr = userManager.createUser(token: token)
                }

                if let currentUsr = currentUsr {
                    if currentUsr.deviceUUID != nil { //already registered
                        let deviceList = scope.getService(DeviceListAPI.self)
                        let coordinator = deviceList.createHomeCoordinator(router: router, user: currentUsr, token: token)
                        router.push(view: AnyView(coordinator.createHomePage().navigationBarHidden(true)))
                    } else { //need register device
                        viewModel?.registerDevice(token)
                    }
                } else {
                    error = true
                }
            } else {
                error = true
            }
        }

        if let viewModel = viewModel {
            if error {
                viewModel.error = AuthError.fail(message: "Invalid token")
            }
        }
    }

    func didRegisterDevice(_ viewModel: LoginViewModel?, token: String, deviceUUID: String) {
        let session = scope.getService(SessionAPI.self)
        let userManager = scope.getService(UserAPI.self)

        if let email = session.email(token: token), var user = userManager.user(email: email) {
            user.deviceUUID = deviceUUID
            userManager.setUser(user, for: email)
            let deviceList = scope.getService(DeviceListAPI.self)
            let coordinator = deviceList.createHomeCoordinator(router: router, user: user, token: token)
            router.push(view: AnyView(coordinator.createHomePage().navigationBarHidden(true)))
            return
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
