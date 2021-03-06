//
//  LoginModel.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Foundation

struct RegisterModel {
    var name: String
    var email: String
    var password: String
}

struct LoginModel {
    var email: String
    var password: String
}

struct ResetPasswordModel {
    var email: String
}

struct LoginResult {
    var token: String?
    var refreshToken: String?
    var expires_at: String?
}

struct RegisterResult {
    var id: String?
}

struct ResetResult {
    var id: String?
}

struct RegisterDeviceResult {
    var id: String?
}

enum AuthError: Error, Hashable {
    case success(message: String)
    case fail(message: String)
    case none
}
