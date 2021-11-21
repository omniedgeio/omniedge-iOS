//
//  UserManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/21.
//

import Foundation
import KeychainAccess
import Tattoo

public class UserManager: UserAPI {
    public init(scope: Scope) {
    }

    public func user(email: String) -> User? {
        if let user = UserDefaults.standard.value(forKey: email) as? User {
            return user
        } else {
            return nil
        }
    }

    public func setUser(_ user: User, for email: String) {
        UserDefaults.standard.set(user, forKey: email)
    }

    public func createUser(token: String) -> User? {
        let dict = JWTUtil.decode(jwtToken: token)
        guard !dict.isEmpty else {
            return nil
        }
        guard let email = dict[Session.emailKey] as? String, let name = dict[Session.nameKey] as? String else {
            return nil
        }
        var user = User(email: email, name: name)
        if let imageURL = dict[Session.pictureURLKey] as? String {
            user.picture = imageURL
        }

        UserDefaults.standard.set(user, forKey: email)
        return user
    }
}
