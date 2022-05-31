
import UIKit

public final class RoutingManagerImpl: RoutingManager {
    public var navigationFactory: OMENavigationFactory = DefaultNavigationFactory()

    private(set) var interceptors: [RoutingInterceptor] = []

    public init() {}

    public func createRouter() -> RoutingAPI {
        setupNewRouter().router
    }

    private func addSalt() {}

    public func registerInterceptor(_ interceptor: RoutingInterceptor) {
        interceptors.append(interceptor)
    }
}

extension RoutingManagerImpl: OMEInterceptProvider {}

extension RoutingManagerImpl: NewRouterProvider {
    func setupNewRouter() -> OMENewRouterSetup {
        let navigationController = navigationFactory.makeNavigationController()
        let navigationRouter = NavigationRouter(navigationController, routerProvider: self)

        let interceptor = OMEInterceptRouter(router: navigationRouter, interceptorProvider: self)
        return OMENewRouterSetup(navigationController: navigationController, router: interceptor)
    }
}

final class DefaultNavigationFactory: OMENavigationFactory {
    func makeNavigationController() -> UINavigationController {
        let result = UINavigationController()
        result.navigationBar.prefersLargeTitles = true
        return result
    }
}

