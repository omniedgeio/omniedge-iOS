
import Combine
import UIKit

public struct RoutingInterceptorResult {
    public var canProceed: Bool
    public var parameters: RoutingParameters?
    public var proceedWithNewRouter: RoutingAPI?

    public init(canProceed: Bool,
                parameters: RoutingParameters? = nil,
                proceedWithNewRouter: RoutingAPI? = nil) {
        self.canProceed = canProceed
        self.parameters = parameters
        self.proceedWithNewRouter = proceedWithNewRouter
    }
}

public protocol RoutingInterceptor: AnyObject {
    func allowTransition(_ parameters: RoutingParameters, router: RoutingAPI) -> Bool
    func handleInterrupt(parameters: RoutingParameters, router: RoutingAPI) -> Future<RoutingInterceptorResult, Never>
}


public protocol OMENavigationFactory {
    func makeNavigationController() -> UINavigationController
}

public protocol RoutingManager: AnyObject {

    var navigationFactory: OMENavigationFactory { get set }

    func createRouter() -> RoutingAPI

    func registerInterceptor(_ interceptor: RoutingInterceptor)
}
