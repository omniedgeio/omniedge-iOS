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
    static private let guid = "S4K8QNVVRR.com.omniedge.client"
    static private let tokenKey = "token"
    static private let expireKey = "exp"
    static private let nameKey = "name"
    static private let emailKey = "email"
    static private let pictureURLKey = "imageURL"

    public var token: String?
    public var user: User?
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
        
        if let name = dict[Self.nameKey] as? String {
            keychain[Self.nameKey] = name
        }

        if let email = dict[Self.emailKey] as? String {
            keychain[Self.emailKey] = email
        }

        if let expire = dict[Self.expireKey] as? String {
            keychain[Self.expireKey] = expire
        }

        keychain[Self.tokenKey] = token

        loadFromKeychain()
        return true
    }

    public func logout() {
        let keychain = Keychain(service: Self.guid)
        do {
            try keychain.removeAll()
            self.token = nil
            self.user = nil
            self.expire = nil
        } catch {
            //
        }
    }

    private func loadFromKeychain() {
        let keychain = Keychain(service: Self.guid)
        token = keychain[Self.tokenKey]

        if let expireString = keychain[Self.expireKey], let time = Double(expireString) {
            expire = Date(timeIntervalSince1970: time)
        }

        if let name = keychain[Self.nameKey], let email = keychain[Self.emailKey] {
            user = User(name: name, email: email, picture: keychain[Self.pictureURLKey])
        }
    }
}
