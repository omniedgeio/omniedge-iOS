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
    typealias ReturnType = LoginNetworkResult
    var path: String = "/devices/register"

    var body: [String: Any]? {
        let uuid: String = UIDevice.current.identifierForVendor?.uuidString ?? "hardware_uuid-1-2-3-4"
        return ["name": UIDevice.current.name,
                "hardware_uuid": uuid,
                "os": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"]
    }
}
