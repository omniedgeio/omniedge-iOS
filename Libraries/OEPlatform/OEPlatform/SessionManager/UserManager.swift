//
//  UserManager.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/21.
//

import Foundation
import Tattoo

public class UserManager: UserAPI {
    let scope: APICenter

    public init(scope: APICenter) {
        self.scope = scope
    }

    public func user(email: String) -> User? {
        if let user: User? = scope.userDefaults().getDecodable(for: email) {
            return user
        } else {
            return nil
        }
    }

    public func setUser(_ user: User, for email: String) {
        do {
            try scope.userDefaults().setEncodable(user, for: email)
        } catch {
            //
        }
    }

    public func createUser(token: String) -> User? {
        guard let jwt = token.jwt, let email = jwt.email, let name = jwt.name else {
            return nil
        }
        let user = User(email: email, name: name)
        do {
            try scope.userDefaults().setEncodable(user, for: email)
        } catch {
            return nil
        }
        return user
    }

    public func clear() {
        if let identifier = Bundle.main.bundleIdentifier {
            scope.userDefaults().removePersistentDomain(forName: identifier)
        }
    }
}

extension UserDefaults {
    func setEncodable<T: Encodable>(_ encodable: T, for key: String) throws {
        let data = try PropertyListEncoder().encode(encodable)
        self.set(data, forKey: key)
    }

    func getDecodable<T: Decodable>(for key: String) -> T? {
        guard
            self.object(forKey: key) != nil,
            let data = self.value(forKey: key) as? Data
        else {
            return nil
        }

        let obj = try? PropertyListDecoder().decode(T.self, from: data)
        return obj
    }
}
