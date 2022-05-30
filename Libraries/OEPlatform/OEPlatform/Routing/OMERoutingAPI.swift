
import Combine
import SwiftUI
import Tattoo
import UIKit

/// The parameters used for navigating in our app.
///
/// You can use it to customize the transition
public struct RoutingParameters: Hashable {
    /// Should the transition be animated
    ///
    /// Defaults to true.
    public var animated = true

    /// Should the transition be blocked if there isn't a user signed in.
    ///
    /// Defaults to true
    public var allowGuest = true

    /// Should the user be allowed to dismiss this screen (pop or drag down)
    ///
    /// Defaults to true
    public var allowDismiss = true

    /// By default, presentation opens a new navigation stack in the presented screen.
    /// Set this to true to present a simple view or manage the navigation internally
    ///
    /// Defaults to false
    public var plainPresentation = false

    /// Use this property to show a full screen overlay above the current navigation stack.
    /// Default of this property is `false`. This property will take effect only in calls to `present()`
    ///
    /// Setting this property to true will change the presentation of the screen to be over the full screen.
    /// In addition - the transition will become cross-dissolve.
    public var fullScreenOverlay = false

    /// Creates a new instance
    public init() {}

    /// Creates a new instance
    public init(animated: Bool = true,
                allowGuest: Bool = true,
                allowDismiss: Bool = true,
                plainPresentation: Bool = false,
                fullScreenOverlay: Bool = false) {
        self.animated = animated
        self.allowGuest = allowGuest
        self.allowDismiss = allowDismiss
        self.plainPresentation = plainPresentation
        self.fullScreenOverlay = fullScreenOverlay
    }

}

/// A handle which can be used to dismiss/pop the previously presented/pushed view.
///
/// Use this class to unwind the navigation in our app and return to a previous state.
public protocol UnwindingHandle: AnyObject {
    /// Used to monitor if the presented view was dismissed.
    ///
    /// If the user dismissed/popped the screen it would trigger this event.
    /// Also triggered for programmatic dismissal (say if you popped to the root view controller)
    var didUnwind: AnyPublisher<Void, Never> { get }

    /// - returns: Returns true if the presented/pushed view are still active and can be dismissed
    var canUnwind: Bool { get }

    /// This property will hold a publisher for a newly created router.
    ///
    /// When you present a view/viewcontroller in a new navigation stack, it can produce a new router to be used.
    var presentedRouter: AnyPublisher<RoutingAPI, Never> { get }
}

/// A basic router which can be used for navigating in our app.
///
/// You can think of this router as a simple wrapper on top of a UINavigationController
/// which can manage both SwiftUI and UIKit
public protocol RoutingAPI: AnyObject {
    /// Pushes a SwiftUI view into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle

    /// Presents a SwiftUI view on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(view: AnyView, parameters: RoutingParameters) -> UnwindingHandle

    /// Pushes a UIKit view controller into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle

    /// Presents a UIKit view controller on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(viewController: UIViewController, parameters: RoutingParameters) -> UnwindingHandle

    /// Pop or dimiss a previously pushed/presented view/view-controller
    ///
    /// - returns: Returns true if the view was unwound, false if it was already dismissed.
    @discardableResult
    func unwind(_ handle: UnwindingHandle) -> Bool
}

public extension RoutingAPI {
    /// Pushes a SwiftUI view into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(view: AnyView) -> UnwindingHandle {
        return push(view: view, parameters: RoutingParameters())
    }

    /// Presents a SwiftUI view on top of the current navigation stack.
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(view: AnyView) -> UnwindingHandle {
        return present(view: view, parameters: RoutingParameters())
    }

    /// Pushes a UIKit view controller into view the navigation stack
    ///
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func push(viewController: UIViewController) -> UnwindingHandle {
        return push(viewController: viewController, parameters: RoutingParameters())
    }

    /// Presents a UIKit view controller on top of the current navigation stack.
    /// 
    /// - returns: A handle which you can use to call `unwind` or monitor for dismissal
    @discardableResult
    func present(viewController: UIViewController) -> UnwindingHandle {
        return present(viewController: viewController, parameters: RoutingParameters())
    }
}

public extension APICenter {
    /// Obtain the registered router in this scope.
    func router() -> RoutingAPI {
        return Tattoo.get(RoutingAPI.self, self)
    }
}
