//
//  Login.swift
//  Login
//
//

import Foundation
import OEPlatform

/// Document your module purpose
class Login: LoginAPI {
    public func createLoginCoordinator() -> LoginCoordinator {
        return LoginCoordinatorImpl()
    }

    public init() {
    }
}
