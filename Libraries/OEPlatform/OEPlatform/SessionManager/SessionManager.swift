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
}

public extension String {
    struct JWTUser {
        public var name: String?
        public var email: String?
    }
    var jwt: JWTUser? {
        let dict = JWTUtil.decode(jwtToken: self)
        guard !dict.isEmpty else {
            return nil
        }

        if let data = dict[Session.dataKey] as? [String: Any],
           let user = data[Session.usrKey] as? [String: Any] {
            return JWTUser(name: user[Session.nameKey] as? String, email: user[Session.emailKey] as? String)
        }
        return nil
    }
}
