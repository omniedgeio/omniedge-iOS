
import SwiftUI
import Tattoo

public struct OMENavigationView<Content: View>: View {

    let routingManager: NewRouterProvider

    let viewProvider: (RoutingAPI) -> Content

    public init(scope: APICenter, @ViewBuilder content: @escaping (RoutingAPI) -> Content) {
        self.routingManager = scope.newRouterProvider
        self.viewProvider = content
    }

    private func beginSalt() {
    }

    public var body: some View {
        let navigationController = createNewNavigationController()
        NAVControllerWrapper(navigationController: navigationController)
            .onPreferenceChange(NAVBarTintColorKey.self, perform: { value in
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
        OMENavigationView(scope: scope) { _ in
            Text("world!")
                .navigationTitle("Hello")
        }
    }
}

extension APICenter {
    var newRouterProvider: NewRouterProvider {
        let routingManager = getService(RoutingManager.self) as? NewRouterProvider
        return routingManager ?? getService(NewRouterProvider.self)
    }
}
