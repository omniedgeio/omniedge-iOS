//
//  LoginAPI.swift
//  OEPlatform
//
//

import Foundation
import SwiftUI

/// The Login public APIs to be used by other modules
public protocol LoginCoordinator: Coordinator {
    func createLoginView() -> AnyView
}

public protocol LoginAPI {
    // TODO - add the public APIs here
    func createLoginCoordinator(router: RoutingAPI) -> LoginCoordinator
}
