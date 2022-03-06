//
//  DeviceListDataProvider.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/6.
//

import Combine
import OENetwork

class DeviceListDataProvider: DeviceListDataStoreAPI {
    private var cancellables = [AnyCancellable]()
    #if false
    private let network = OENetwork(baseURL: "https://dev-api.omniedge.io/api/v1")
    #else
    private let network = OENetwork(baseURL: "https://api.omniedge.io/api/v1")
    #endif

    func fetchNetworkList(_ request: NetworkListRequest) -> AnyPublisher<NetworkListModel, DataError> {
        return network.dispatch(FetchNetworkListRequst(token: request.token))
            .compactMap({ [weak self] result in
                return self?.createNetworkList(result.data)
            })
            .mapError { error in
                return DataError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    private func createNetworkList(_ data: [NetworkModel]?) -> NetworkListModel {
        if let list = data {
            return NetworkListModel(list: list)
        } else {
            return NetworkListModel(list: [])
        }
    }

    func fetchDeviceList(_ request: DeviceListRequest) -> AnyPublisher<DeviceListModel, DataError> {
        return network.dispatch(FetchDeviceListRequst(token: request.token))
            .compactMap({ [weak self] result in
                return self?.createDeviceList(message: result.message, dict: result.data)
            })
            .mapError { error in
                return DataError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    private func createDeviceList(message: String, dict: [String: String]?) -> DeviceListModel {
        return DeviceListModel(list: [])
    }

    func joinNetwork(_ request: JoinRequest) -> AnyPublisher<N2NModel, DataError> {
        return network.dispatch(JoinNetworkRequst(token: request.token, uuid: request.uuid, deviceUUID: request.deviceID))
            .compactMap({ result in
                return result.data
            })
            .mapError { error in
                return DataError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
