//
//  SessionAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/10/31.
//

import Foundation

public protocol SessionAPI {
    func login(token: String) -> Bool
    func logout()
    func email(token: String) -> String?
    var token: String? { get }
}

public struct Session {
    static public let emailKey = "email"
    public static let nameKey = "name"
    static public let tokenKey = "token"
    static public let expireKey = "exp"
    static public let uuidKey = "uuid"
    static public let pictureURLKey = "imageURL"

}
