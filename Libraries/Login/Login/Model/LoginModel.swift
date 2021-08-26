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

struct LoginResult: Codable {
    var message: String
    var data: String?
}

enum AuthError: Error, Hashable {
    case success(message: String)
    case fail(message: String)
    case none
}
