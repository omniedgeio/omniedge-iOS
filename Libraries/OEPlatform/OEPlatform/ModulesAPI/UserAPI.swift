//
//  UserAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/21.
//

import Foundation

public struct User {
    /// from token
    public var email: String
    public var name: String
    public var picture: String?
    public var deviceUUID: String? /// from register
    public var network: NetworkInfo?
}

public struct NetworkInfo {
    var networkUUID: String /// from list network
    var ip: String /// from join network
}

public protocol UserAPI {
    func createUser(token: String) -> User?
    func user(email: String) -> User?
}
