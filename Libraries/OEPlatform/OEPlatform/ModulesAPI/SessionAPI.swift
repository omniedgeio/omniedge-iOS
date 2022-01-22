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
    var token: String? { get }
}
