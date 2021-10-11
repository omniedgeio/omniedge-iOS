//
//  RoutingManagerImpl.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-24.
//

import UIKit

/// A platform provided routing manager which is using an underlying UINavigationController to manage the app navigation.
public final class RoutingManagerImpl: RoutingManager {
    public var navigationFactory: NavigationFactory = DefaultNavigationFactory()

    private(set) var interceptors: [RoutingInterceptor] = []

    public init() {}

    public func createRouter() -> RoutingAPI {
        setupNewRouter().router
    }

    public func registerInterceptor(_ interceptor: RoutingInterceptor) {
        interceptors.append(interceptor)
    }
}

extension RoutingManagerImpl: InterceptorProvider {}

extension RoutingManagerImpl: NewRouterProvider {
    func setupNewRouter() -> NewRouterSetup {
        let navigationController = navigationFactory.makeNavigationController()
        let navigationRouter = NavigationRouter(navigationController, routerProvider: self)

        let interceptor = InterceptingRouter(router: navigationRouter, interceptorProvider: self)
        return NewRouterSetup(navigationController: navigationController, router: interceptor)
    }
}
