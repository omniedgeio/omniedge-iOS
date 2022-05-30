//
//  SHNavigationView.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-29.
//

import SwiftUI
import Tattoo

/// Use a SHNavigationView to obtain a router which you can pass to other modules
///
/// The SHNavigationView can be seen as our replacement for SwiftUI NavigationView
public struct SHNavigationView<Content: View>: View {

    let routingManager: NewRouterProvider

    let viewProvider: (RoutingAPI) -> Content

    /// Creates a new instance. The scope you pass along must hold a `RoutingManager`
    ///
    /// The content which you provide is the root of the new navigation stack. Your code should hold on to the routing API and pass it to the dependent modules
    public init(scope: APICenter, @ViewBuilder content: @escaping (RoutingAPI) -> Content) {
        self.routingManager = scope.newRouterProvider
        self.viewProvider = content
    }

    public var body: some View {
        let navigationController = createNewNavigationController()
        NavigationControllerWrapper(navigationController: navigationController)
            .onPreferenceChange(NavigationBarTintColorKey.self, perform: { value in
                navigationController.navigationBar.tintColor = value.map { UIColor($0) }
            })
    }

    private func createNewNavigationController() -> UINavigationController {
        let setup = routingManager.setupNewRouter()
        let child = AnyView(viewProvider(setup.router))
        _ = setup.router.push(view: child)
        return setup.navigationController
    }
}

struct SHNavigationView_Previews: PreviewProvider {
    static let scope: APICenter = {
        let result = APICenter()
        result.registerService(RoutingManager.self, RoutingManagerImpl.init)
        return result
    }()
    static var previews: some View {
        SHNavigationView(scope: scope) { _ in
            Text("world!")
                .navigationTitle("Hello")
        }
    }
}

/// An internal extension for scope used to expose the internal `NewRouterProvider`
extension APICenter {
    var newRouterProvider: NewRouterProvider {
        let routingManager = getService(RoutingManager.self) as? NewRouterProvider
        return routingManager ?? getService(NewRouterProvider.self)
    }
}
