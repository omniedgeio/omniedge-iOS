//
//  SessionManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/10/31.
//

import Foundation
import Tattoo

public class SessionManager: SessionAPI {
    public let token: String

    public init(scope: Scope) {
        token = ""
    }

    public func login(token: String) -> Bool {
        let dict = JWTUtil.decode(jwtToken: token)


        return true
    }

    public func logout() {
    }
}
