//
//  UserAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/21.
//

import Foundation

public class User: Codable {
    /// from token
    public var email: String
    public var name: String
    public var picture: String?
    public var deviceUUID: String? /// from register
    public var network: OENetworkInfo?

    public init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}

public struct OENetworkInfo: Codable {
    public var networkUUID: String /// from list network
    public var ip: String /// from join network
    public init(networkUUID: String, ip: String) {
        self.networkUUID = networkUUID
        self.ip = ip
    }
}

public protocol UserAPI {
    func createUser(token: String) -> User?
    func user(email: String) -> User?
    func setUser(_ user: User, for email: String)
    func clear()
}
