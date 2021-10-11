//
//  InterceptingRouter.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-24.
//

import Combine
import SwiftUI
import UIKit

/// An internal protocol for an object that provides interceptors
protocol InterceptorProvider {
    var interceptors: [RoutingInterceptor] { get }
}

private typealias NavigationBlock = (RoutingAPI, RoutingParameters) -> UnwindingHandle

/// A platform provided router which consults with the navigation interceptors prior to performing the transition.
class InterceptingRouter: RoutingAPI {
    private let interceptorProvider: InterceptorProvider
    private let router: RoutingAPI
    private var subscriptions = Set<AnyCancellable>()

    /// Creates a new instance and holds strong references to the provided `router` and `interceptorProvider`
    init(router: RoutingAPI, interceptorProvider: InterceptorProvider) {
        self.interceptorProvider = interceptorProvider
        self.router = router
    }

    private func tryToNavigate(_ parameters: RoutingParameters,
                               navigation: @escaping NavigationBlock) -> InterceptionHandle {
        let result = InterceptionHandle()
        tryToNavigate(parameters,
                      interceptors: interceptorProvider.interceptors,
                      router: router,
                      handle: result,
                      navigation: navigation)
        return result
    }

    private func tryToNavigate(_ parameters: RoutingParameters,
                               interceptors: [RoutingInterceptor],
                               router: RoutingAPI,
                               handle: InterceptionHandle,
                               navigation: @escaping NavigationBlock) {
        let shouldIntercept: (RoutingInterceptor) -> Bool = { !$0.allowTransition(parameters, router: self) }
        guard let interceptorIndex = interceptors.firstIndex(where: shouldIntercept) else {
            handle.acceptHandle(navigation(router, parameters))
            return
        }
        let interceptor = interceptors[interceptorIndex]
        interceptor.handleInterrupt(parameters: parameters, router: self).sink { [weak self, weak router] result in
            guard result.canProceed else {
                debugPrint("Interceptor \(interceptor) blocked the transition")
                return
            }
            guard let self = self,
                  let router = router else {
                debugPrint("This router was deallocated.")
                return
            }
            var newInterceptors = interceptors
            newInterceptors.remove(at: interceptorIndex)
            self.tryToNavigate(result.parameters ?? parameters,
                               interceptors: newInterceptors,
                               router: result.proceedWithNewRouter ?? router,
                               handle: handle,
                               navigation: navigation)
        }.store(in: &subscriptions)
    }

    /// Pushes a SwiftUI view into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle {
        tryToNavigate(parameters) { router, parameters in
            router.push(view: view, parameters: parameters)
        }
    }

    /// Presents a SwiftUI view on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle {
        tryToNavigate(parameters) { router, parameters in
            router.present(view: view, parameters: parameters)
        }
    }

    /// Pushes a UIKit view controller into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle {
        tryToNavigate(parameters) { router, parameters in
            router.push(viewController: viewController, parameters: parameters)
        }
    }

    /// Presents a UIKit view controller on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle {
        tryToNavigate(parameters) { router, parameters in
            router.present(viewController: viewController, parameters: parameters)
        }
    }

    /// Pop or dimiss a previously pushed/presented view/view-controller
    ///
    /// - returns: Returns true if the view was unwound, false if it was already dismissed.
    @discardableResult
    func unwind(_ handle: UnwindingHandle) -> Bool {
        guard let interceptionHandle = handle as? InterceptionHandle,
              let innerHandle = interceptionHandle.handle else {
            return false
        }
        return router.unwind(innerHandle)
    }
}

class InterceptionHandle: UnwindingHandle {
    private(set) var handle: UnwindingHandle?
    private var subscriptions = Set<AnyCancellable>()

    private let _didUnwind = PassthroughSubject<Void, Never>()
    private let _presentedRouter = PassthroughSubject<RoutingAPI, Never>()

    func acceptHandle(_ handle: UnwindingHandle?) {
        guard self.handle == nil else {
            return
        }
        self.handle = handle
        handle?.didUnwind.subscribe(_didUnwind).store(in: &subscriptions)
        handle?.presentedRouter.subscribe(_presentedRouter).store(in: &subscriptions)
    }

    var didUnwind: AnyPublisher<Void, Never> {
        _didUnwind.eraseToAnyPublisher()
    }

    var canUnwind: Bool {
        handle?.canUnwind ?? false
    }

    var presentedRouter: AnyPublisher<RoutingAPI, Never> {
        _presentedRouter.eraseToAnyPublisher()
    }
}
