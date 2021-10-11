//
//  RouterManager.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-22.
//

import Combine
import UIKit

/// The answer provided by a routing intercetpor
public struct RoutingInterceptorResult {
    /// Should the navigation proceed or stop entirely
    public var canProceed: Bool
    /// The parameters to proceed with. Interceptor may change it
    public var parameters: RoutingParameters?
    /// The router to proceed with. The interceptor may change it
    public var proceedWithNewRouter: RoutingAPI?

    /// Create a new interception answer
    public init(canProceed: Bool,
                parameters: RoutingParameters? = nil,
                proceedWithNewRouter: RoutingAPI? = nil) {
        self.canProceed = canProceed
        self.parameters = parameters
        self.proceedWithNewRouter = proceedWithNewRouter
    }
}

/// A routing interceptor can add new views/view-controllers when the app navigates from one part to the other
///
/// A good example for an interceptor is one which checks for `allowGuest` and injects the login flow.
public protocol RoutingInterceptor: AnyObject {
    /// Checks if the transition is allowed to proceed.
    ///
    /// - returns: Return `false` and the interceptor will be sent a `handleInterrupt` based on priority
    func allowTransition(_ parameters: RoutingParameters, router: RoutingAPI) -> Bool

    /// If this interceptor returned `false` for `allowTransition` this function will be called
    ///
    /// - returns: Return a future which will determine if the transition can continue or stopped entirely.
    func handleInterrupt(parameters: RoutingParameters, router: RoutingAPI) -> Future<RoutingInterceptorResult, Never>
}

/// This factory creates a navigation controller on-demand.
public protocol NavigationFactory {
    /// Creates a new navigation controller
    /// - note: The navigation controller delegate will be overwritten
    func makeNavigationController() -> UINavigationController
}

/// An app wide routing manager.
/// Reponsible for creating new routers around a navigation controller.
public protocol RoutingManager: AnyObject {

    /// Gets or sets the navigation factory used to create new routers with.
    var navigationFactory: NavigationFactory { get set }

    /// Creates a new router with a specific navigation controller.
    ///
    /// There should be a router in each "scope" in the app. You can imagine one for each tab and
    /// for each presented view controller
    func createRouter() -> RoutingAPI

    /// Registers a new routing interceptor.
    ///
    /// - important: The interceptors priority is based on their registration order. First interceptor takes higher priority.
    func registerInterceptor(_ interceptor: RoutingInterceptor)
}
