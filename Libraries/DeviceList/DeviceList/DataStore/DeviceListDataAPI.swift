//
//  DeviceListDataAPI.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/6.
//

import Combine
import Foundation

struct NetworkListRequest {
    let token: String
}

struct DeviceListRequest {
    let token: String
}

struct JoinRequest {
    let uuid: String
    let deviceID: String
    let token: String
}

protocol DeviceListDataStoreAPI {
    func fetchNetworkList(_ request: NetworkListRequest) -> AnyPublisher<NetworkListModel, DataError>
    func fetchDeviceList(_ request: DeviceListRequest) -> AnyPublisher<DeviceListModel, DataError>
    func joinNetwork(_ request: JoinRequest) -> AnyPublisher<N2NModel, DataError>
}
