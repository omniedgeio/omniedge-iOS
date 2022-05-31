//
//  SessionManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/10/31.
//

import Foundation
import KeychainAccess
import Tattoo

struct Session {
    public static let dataKey = "data"
    public static let usrKey = "user"
    public static let emailKey = "email"
    public static let nameKey = "name"
    public static let tokenKey = "token"
    public static let expireKey = "exp"
    public static let uuidKey = "uuid"
    public static let pictureURLKey = "imageURL"
}

public class SessionManager: SessionAPI {
    public var token: String?
    static private let guid = "S4K8QNVVRR.com.omniedge.client"
    private var expire: Date?

    public init(scope: APICenter) {
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
