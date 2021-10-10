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

class LoginCoordinatorImpl: LoginCoordinator, LoginDelegate {
    var dataStore: LoginDataStoreAPI
    var viewModel: LoginViewModel

    init() {
        dataStore = LoginDataStoreMock()
        viewModel = LoginViewModel(dataStore)
        viewModel.delegate = self
    }

    func createLoginView() -> AnyView {
        return AnyView(LoginView(viewModel: viewModel))
    }

    func didLogin(token: String) {
        print("login ok")
    }

    func didRegister(email: String, password: String) {
    }

    func didReset(email: String) {
    }
}
