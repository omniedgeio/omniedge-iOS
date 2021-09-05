//
//  LoginNetworkProvider.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Foundation
import OENetwork

struct LoginNetworkResult: Codable {
    var message: String
    var data: [String: String]?
}

struct RegisterRequst: Request {
    typealias ReturnType = LoginNetworkResult
    var name: String
    var email: String
    var password: String

    var path: String = "/auth/register"
    var body: [String: Any]? {
        ["name": name,
         "email": email,
         "password": password,
         "confirm_password": password,
         "auth_session_uuid": "e9497ac1-f33d-41d9-b868-ad1035854610"]
    }
}

struct LoginRequest: Request {
    let email: String
    let password: String
    typealias ReturnType = LoginNetworkResult
    var path: String = "/auth/login/password"
    var body: [String: Any]? {
        ["email": email,
         "password": password,
         "auth_session_uuid": "e9497ac1-f33d-41d9-b868-ad1035854610"]
    }
}

struct ResetPasswordRequest: Request {
    typealias ReturnType = LoginNetworkResult
    var email: String
    var path: String = "/auth/reset-password/code"
    var body: [String: Any]? {
        ["email": email]
    }
}
