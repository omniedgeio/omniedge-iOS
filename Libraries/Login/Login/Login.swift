//
//  Login.swift
//  Login
//
//

import Foundation
import OEPlatform
import Tattoo

public class Login: LoginAPI {
    private let scope: APICenter

    public init(scope: APICenter) {
        self.scope = scope
    }

    public func createLoginCoordinator(router: RoutingAPI) -> LoginCoordinator {
        return LoginCoordinatorImpl(scope: scope, router: router)
    }
}
