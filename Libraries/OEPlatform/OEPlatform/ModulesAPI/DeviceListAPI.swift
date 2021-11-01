//
//  DeviceListAPI.swift
//  OEPlatform
//
//

import Foundation
import SwiftUI
import Tattoo

public protocol DeviceListCoordinator: Coordinator {
    func createHomePage() -> AnyView
}

public protocol DeviceListAPI {
    func createHomeCoordinator(router: RoutingAPI, user: User) -> DeviceListCoordinator
}
