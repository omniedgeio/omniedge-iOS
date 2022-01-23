//
//  LoginNetworkProvider.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Foundation
import OENetwork
import UIKit

struct RegisterNetworkResult: Codable {
    struct RegisterInfo: Codable {
        var id: String?
    }
    var data: RegisterInfo?
}

struct RegisterRequst: Request {
    typealias ReturnType = RegisterNetworkResult
    var name: String
    var email: String
    var password: String

    var path: String = "/auth/register"
    var body: [String: Any]? {
        ["name": name,
         "email": email,
         "password": password]
    }
}

struct LoginNetworkResult: Codable {
    struct LoginInfo: Codable {
        var token: String?
        var refreshToken: String?
        var expires_at: String?
    }

    var data: LoginInfo?
}

struct LoginRequest: Request {
    let email: String
    let password: String
    typealias ReturnType = LoginNetworkResult
    var path: String = "/auth/login/password"
    var body: [String: Any]? {
        ["email": email,
         "password": password]
    }
}

struct ResetPasswordNetworkResult: Codable {
    struct Info: Codable {
        var status: String?
    }
    var data: Info?
}

struct ResetPasswordRequest: Request {
    typealias ReturnType = ResetPasswordNetworkResult
    var email: String
    var path: String = "/auth/reset-password/code"
    var body: [String: Any]? {
        ["email": email]
    }
}

struct RegisterDeviceNetworkResult: Codable {
    struct Info: Codable {
        var id: String?
        var name: String?
        var hardware_id: String?
    }
    var data: Info?
}
/*
 //register device
 {
     "message": "Register device successfully",
     "data": {
         "uuid": "1534e554-25f8-47ec-9b53-14f37a58f7b0",
         "name": "GL-MIFI",
         "os": "OpenWrt GCC 7.3.0 r7258-5eb055306f"
     }
 }
 */
struct RegisterDeviceRequest: Request {
    let token: String?
    typealias ReturnType = RegisterDeviceNetworkResult
    var path: String = "/devices/register"

    var body: [String: Any]? {
        let uuid: String = UIDevice.current.identifierForVendor?.uuidString ?? "hardware_uuid-1-2-3-4"
        return ["name": UIDevice.current.name,
                "hardware_uuid": uuid,
                "platform": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"]
    }
}
