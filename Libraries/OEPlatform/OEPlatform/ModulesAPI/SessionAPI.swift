//
//  SessionAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/10/31.
//

import Foundation

public struct User {
    var name: String
    var email: String
    var uuid: String
    var token: String
    var picture: String?
}

public protocol SessionAPI {
    func login(token: String, uuid: String) -> Bool
    func logout()
    var user: User? { get }
}
