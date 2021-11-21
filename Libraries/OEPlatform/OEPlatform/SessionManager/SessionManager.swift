//
//  SessionManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/10/31.
//

import Foundation
import KeychainAccess
import Tattoo

public class SessionManager: SessionAPI {
    public var token: String?
    static private let guid = "S4K8QNVVRR.com.omniedge.client"
    private var expire: Date?

    public init(scope: Scope) {
        loadFromKeychain()
    }

    public func login(token: String) -> Bool {
        let keychain = Keychain(service: Self.guid)

        let dict = JWTUtil.decode(jwtToken: token)
        guard !dict.isEmpty else {
            return false
        }
        keychain[Session.tokenKey] = token
        self.token = token
        return true
    }

    public func logout() {
        let keychain = Keychain(service: Self.guid)
        do {
            try keychain.removeAll()
            self.expire = nil
        } catch {
            //
        }
    }

    @discardableResult
    private func loadFromKeychain() -> Bool {
        let keychain = Keychain(service: Self.guid)
        if let token = keychain[Session.tokenKey] {
            self.token = token
            return true
        }
        return false
    }

    public func email(token: String) -> String? {
        let dict = JWTUtil.decode(jwtToken: token)
        guard !dict.isEmpty else {
            return nil
        }
        if let email = dict[Session.emailKey] as? String {
            return email
        }
        return nil
    }
}
