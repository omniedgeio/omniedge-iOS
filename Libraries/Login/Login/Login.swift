//
//  Login.swift
//  Login
//
//

import Foundation
import OEPlatform

/// Document your module purpose
public class Login: LoginAPI {
    public func createLoginCoordinator() -> LoginCoordinator {
        return LoginCoordinatorImpl()
    }

    public init() {}
}
