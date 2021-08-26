//
//  LoginViewModel.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import Foundation

class LoginViewModel: ObservableObject {
    var email = ""
    var password = ""
    var dataStoreAPI: LoginDataStoreAPI

    init(_ dataStore: LoginDataStoreAPI) {
        dataStoreAPI = dataStore
    }

    func login(email: String, password: String) {
    }
}

class RegisterViewModel: ObservableObject {
    var name = ""
    var email = ""
    var password = ""

    init(email: String) {
        self.email = email
    }
}

class ResetPasswordViewModel: ObservableObject {
    var email = ""

    init(_ email: String) {
        self.email = email
    }

    func sendInstruction() {
    }
}
