//
//  PlatformModule.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-05-04.
//

import Foundation
import Tattoo

/// The GQL federated endpoint settings.
///
/// - note: The platform assumes there is **one** federated endpoint for each environment.
/// If you need additional endpoints, feel free to register them in your `Scope`.
public struct GQLFederatedEndpoint {
    /// The GQL server address
    var url: URL
    /// If the backend supports APQ - you can set this to `true`. Defaults to `false`
    ///
    /// See more about [APQ here](https://www.apollographql.com/docs/apollo-server/performance/apq/)
    var autoPersistQueries: Bool

    /// Configure the GQL federated endpoint
    ///
    /// - parameter url: The GQL server address
    /// - parameter autoPersistQueries: If the backend supports [APQ](https://www.apollographql.com/docs/apollo-server/performance/apq/) -
    /// you can set this to `true`. Defaults to `false`
    public init(url: URL, autoPersistQueries: Bool = false) {
        self.url = url
        self.autoPersistQueries = autoPersistQueries
    }
}

/// A module which can help setting up the production services which are using the platform implementations
///
/// Consumers may choose different services and use granular platform implementation using the various `setupPlatform*` methods
public class PlatformModule: ProductionModule {
    public init() {}

    public func addProductionServices(_ scope: APICenter) {
        scope.setupPlatformNotificationCenter()
        scope.setupPlatformRouting()
        scope.setupPlatformUserDefaults()
    }
}

public extension APICenter {

    // MARK: - Routing
    /// Configures routing in this scope
    func setupPlatformRouting() {
        registerService(RoutingManager.self, RoutingManagerImpl.init)
    }

    // MARK: - Notification center

    func notificationCenter() -> NotificationCenter {
        getService(NotificationCenter.self)
    }

    func setupPlatformNotificationCenter() {
        registerService(NotificationCenter.self, { NotificationCenter.default })
    }

    // MARK: - User Defaults

    func userDefaults() -> UserDefaults {
        getService(UserDefaults.self)
    }

    func setupPlatformUserDefaults() {
        registerService(UserDefaults.self, { UserDefaults.standard })
    }
}
