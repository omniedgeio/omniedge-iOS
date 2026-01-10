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
    private let network = OENetwork(baseURL: "https://dev-api.omniedge.io/api/v2")
    #else
    private let network = OENetwork(baseURL: "https://api.omniedge.io/api/v2")
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

    // MARK: - Async Implementation
    func fetchNetworkList(_ request: NetworkListRequest) async throws -> NetworkListModel {
        do {
            let result: DataNetworkListResult = try await network.dispatch(FetchNetworkListRequst(token: request.token))
            return result.data.map { NetworkListModel(data: $0) } ?? NetworkListModel(data: PaginatedResponse(meta: nil, data: []))
        } catch {
            throw DataError.fail(message: error.localizedDescription)
        }
    }

    func fetchDeviceList(_ request: DeviceListRequest) async throws -> DeviceListModel {
        do {
            let result: DataNetworkResult = try await network.dispatch(FetchDeviceListRequst(token: request.token))
            return DeviceListModel(list: result.data?.data ?? [])
        } catch {
            throw DataError.fail(message: error.localizedDescription)
        }
    }

    func joinNetwork(_ request: JoinRequest) async throws -> N2NModel {
        do {
            let result: JoinNetworkResult = try await network.dispatch(JoinNetworkRequst(token: request.token, uuid: request.uuid, deviceUUID: request.deviceID))
            if let data = result.data {
                return data
            } else {
                throw DataError.fail(message: "Join Network Error")
            }
        } catch {
            throw DataError.fail(message: error.localizedDescription)
        }
    }
}
