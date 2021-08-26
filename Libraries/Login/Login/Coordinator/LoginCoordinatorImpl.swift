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

class LoginCoordinatorImpl: LoginCoordinator {
    var dataStore: LoginDataStoreAPI
    var viewModel: LoginViewModel

    init() {
        dataStore = LoginDataStoreMock()
        viewModel = LoginViewModel(dataStore)
    }

    func createLoginView() -> AnyView {
        return AnyView(LoginView(viewModel: viewModel))
    }
}
