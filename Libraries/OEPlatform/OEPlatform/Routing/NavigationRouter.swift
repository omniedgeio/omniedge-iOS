//
//  NavigationRouter.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-24.
//

import Combine
import SwiftUI
import UIKit

/// An internal struct for creating new navigation stacks.
struct NewRouterSetup {
    /// The newly created navigation controller
    var navigationController: UINavigationController
    /// The newly created router which will own the navigation controller
    var router: RoutingAPI
}

/// An internal interface for creating new routers and navigation controllers
///
/// This is used by the `NavigationRouter` to launch new navigation stacks
protocol NewRouterProvider: AnyObject {
    func setupNewRouter() -> NewRouterSetup
}

/// A platform provided navigation router which owns and manages the navigation in a UINavigationController
class NavigationRouter: NSObject, RoutingAPI {
    private let routerProvider: NewRouterProvider
    private let navigationController: UINavigationController
    private let navigationHandles = NSMapTable<UIViewController, NavigationRouterHandle>.weakToWeakObjects()

    /// Creates a new navigation router and maintains a strong reference to the navigation controller and provider
    init(_ navigationController: UINavigationController, routerProvider: NewRouterProvider) {
        self.navigationController = navigationController
        self.routerProvider = routerProvider
        super.init()
        navigationController.delegate = self
    }

    /// Pushes a SwiftUI view into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle {
        let host = UIHostingController(rootView: view)
        return push(viewController: host, parameters: parameters)
    }

    /// Presents a SwiftUI view on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle {
        let host = UIHostingController(rootView: view)
        parameters.customizeForPresentation(host: host)
        return present(viewController: host, parameters: parameters)
    }

    /// Pushes a UIKit view controller into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle {
        let result = NavigationRouterHandle(viewController: viewController,
                                            didPush: true,
                                            animated: parameters.animated)
        navigationHandles.setObject(result, forKey: viewController)
        // Default for all of our screens is to hide the bottom bar when any view is being pushed.
        // If in the future the requirements change, we can add this as a new property in the RoutingParameters
        viewController.hidesBottomBarWhenPushed = navigationController.topViewController != nil
        viewController.navigationItem.setHidesBackButton(!parameters.allowDismiss, animated: parameters.animated)
        navigationController.pushViewController(viewController, animated: parameters.animated)
        return result
    }

    /// Presents a UIKit view controller on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle {
        if parameters.plainPresentation {
            return plainPresentation(viewController: viewController, parameters: parameters)
        } else {
            return wrappingPresentation(viewController: viewController, parameters: parameters)
        }
    }

    private func plainPresentation(viewController: UIViewController, parameters: RoutingParameters) -> NavigationRouterHandle {
        let result = NavigationRouterHandle(viewController: viewController,
                                            didPush: false,
                                            animated: parameters.animated)
        viewController.isModalInPresentation = !parameters.allowDismiss
        parameters.customizeForPresentation(viewController: viewController)
        navigationController.present(viewController, animated: parameters.animated)
        if !viewController.isModalInPresentation,
           viewController.presentationController?.delegate == nil {
            viewController.presentationController?.delegate = self
            navigationHandles.setObject(result, forKey: viewController)
        }
        return result
    }

    private func wrappingPresentation(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle {
        let newNavigationStack = routerProvider.setupNewRouter()
        let newParameters = RoutingParameters(animated: false,
                                              allowGuest: true,
                                              allowDismiss: parameters.allowDismiss,
                                              plainPresentation: true)
        newNavigationStack.router.push(viewController: viewController, parameters: newParameters)
        let navigationController = newNavigationStack.navigationController
        let result = plainPresentation(viewController: navigationController, parameters: parameters)
        result.setPresentedRouter(newNavigationStack.router)
        return result
    }

    /// Pop or dimiss a previously pushed/presented view/view-controller
    ///
    /// - returns: Returns true if the view was unwound, false if it was already dismissed.
    @discardableResult
    func unwind(_ handle: UnwindingHandle) -> Bool {
        guard let navigationHandle = handle as? NavigationRouterHandle,
              let viewController = navigationHandle.viewController,
              !navigationHandle.isUnwinding else {
            return false
        }
        if navigationHandle.didPush {
            return tryPop(viewController, handle: navigationHandle)
        } else {
            return tryDismiss(viewController, handle: navigationHandle)
        }
    }

    private func tryDismiss(_ viewController: UIViewController, handle: NavigationRouterHandle) -> Bool {
        guard !viewController.isBeingPresented,
              let presenter = viewController.presentingViewController else {
            return false
        }
        handle.isUnwinding = true
        presenter.dismiss(animated: handle.animated) { [navigationHandles] in
            handle.unwindCompleted()
            navigationHandles.removeObject(forKey: viewController)
        }
        return true
    }

    private func tryPop(_ viewController: UIViewController, handle: NavigationRouterHandle) -> Bool {
        guard viewController == navigationController.topViewController,
              navigationController.viewControllers.count > 1 else {
            return false
        }
        handle.isUnwinding = true
        navigationController.popViewController(animated: handle.animated)
        return true
    }

    /// Compares the navigation controller state to our managed state and reconciles the differences
    private func scanAndNotifyHandles() {
        let viewControllers = navigationController.viewControllers
        var toRemove: [UIViewController] = []
        for key in navigationHandles.keyEnumerator() {
            if let viewController = key as? UIViewController,
               let handle = navigationHandles.object(forKey: viewController),
               handle.didShowPhaseComplete,
               !viewControllers.contains(viewController) {

                handle.unwindCompleted()
                toRemove.append(viewController)
            }
        }
        toRemove.forEach(navigationHandles.removeObject)
    }

    private func checkTabBarVisibility() {
        guard let tabBarController = navigationController.tabBarController,
              let topViewController = navigationController.topViewController else {
            return
        }
        let shouldTabBarBeHidden = topViewController.hidesBottomBarWhenPushed
        tabBarController.setTabBarHidden(shouldTabBarBeHidden)
    }
}

class NavigationRouterHandle: UnwindingHandle {
    private let _presentedRounter = CurrentValueSubject<RoutingAPI?, Never>(nil)
    private let _didUnwind = PassthroughSubject<Void, Never>()

    var presentedRouter: AnyPublisher<RoutingAPI, Never> {
        _presentedRounter
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    weak var viewController: UIViewController?
    let didPush: Bool
    let animated: Bool
    var isUnwinding = false
    private var completed = false

    init(viewController: UIViewController, didPush: Bool, animated: Bool) {
        self.viewController = viewController
        self.didPush = didPush
        self.animated = animated
    }

    var didUnwind: AnyPublisher<Void, Never> {
        _didUnwind.eraseToAnyPublisher()
    }

    var canUnwind: Bool {
        if didPush {
            return viewController?.parent != nil
        } else {
            return viewController?.presentingViewController != nil
        }
    }

    func unwindCompleted() {
        guard !completed else {
            return
        }
        completed = true
        viewController = nil
        isUnwinding = false
        _didUnwind.send()
        _didUnwind.send(completion: Subscribers.Completion<Never>.finished)
    }

    func setPresentedRouter(_ router: RoutingAPI) {
        _presentedRounter.value = router
    }

    var willShowPhaseComplete = false
    var didShowPhaseComplete = false
}

extension NavigationRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        navigationHandles.object(forKey: viewController)?.willShowPhaseComplete = true
        checkTabBarVisibility()
    }
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        navigationHandles.object(forKey: viewController)?.didShowPhaseComplete = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = !viewController.navigationItem.hidesBackButton
        scanAndNotifyHandles()
    }
}

extension NavigationRouter: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let presentedViewController = presentationController.presentedViewController
        navigationHandles.object(forKey: presentedViewController)?.unwindCompleted()
        navigationHandles.removeObject(forKey: presentedViewController)
    }
}

private extension UITabBarController {
    func setTabBarHidden(_ isHidden: Bool) {
        let wasHidden = tabBar.isHidden
        if wasHidden != isHidden {
            // Workaround iOS bugs...
            let wasTranslucent = tabBar.isTranslucent
            tabBar.isTranslucent = false
            tabBar.isHidden = isHidden
            tabBar.isTranslucent = wasTranslucent
            // Workaround iOS bugs...
            // https://stackoverflow.com/a/68813366
            let currentFrame = view.frame
            view.frame = currentFrame.insetBy(dx: 0, dy: 1)
            view.frame = currentFrame
        }
    }
}

private extension RoutingParameters {
    func customizeForPresentation(host: UIHostingController<AnyView>) {
        guard fullScreenOverlay else {
            return
        }
        host.view.backgroundColor = .clear
    }

    func customizeForPresentation(viewController: UIViewController) {
        guard fullScreenOverlay else {
            return
        }
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
    }
}
