//
//  DeviceList.swift
//  DeviceList
//
//

import Foundation
import OEPlatform
import Tattoo

/// Document your module purpose
public class DeviceList: DeviceListAPI, ProductionModule {
    private let scope: APICenter

    public init(scope: APICenter) {
        self.scope = scope
    }

    public func createHomeCoordinator(router: RoutingAPI, user: User, token: String) -> DeviceListCoordinator {
        return DeviceListCoordinatorImpl(scope: scope, router: router, user: user, token: token)
    }

    public func addProductionServices(_ scope: APICenter) {
        scope.registerService(DeviceListDataStoreAPI.self, DeviceListDataProvider.init)
        scope.registerService(DevicePingAPI.self, DevicePingProvider.init)
    }
}

extension APICenter {
    var pingProvider: DevicePingAPI {
        self.getService(DevicePingAPI.self)
    }
    var deviceListProvider: DeviceListDataStoreAPI {
        self.getService(DeviceListDataStoreAPI.self)
    }
}
