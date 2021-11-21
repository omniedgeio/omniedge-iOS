//
//  UserManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/21.
//

import Foundation
import KeychainAccess

public class UserManager: UserAPI {
    public func user(email: String) -> User? {
        return User(email: "", name: "")
    }

    public func createUser(token: String) -> User? {
        let dict = JWTUtil.decode(jwtToken: token)
        guard !dict.isEmpty else {
            return nil
        }

        let writter = UserDefaults.standard

        guard let email = dict[Session.emailKey] as? String, let name = dict[Session.nameKey] as? String else {
            return nil
        }
        writter.set(email, forKey: Session.emailKey)
        writter.set(name, forKey: Session.nameKey)

        if let imageURL = dict[Session.pictureURLKey] as? String {
            writter.set(imageURL, forKey: Session.pictureURLKey)
        }
        return User(email: email, name: name)
    }
}
