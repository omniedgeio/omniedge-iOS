//
//  DeviceListViewModel.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/8.
//

import Combine
import OEPlatform
import Foundation

protocol DeviceListDelegate: AnyObject {
    func logout() -> Void
    func didLoadNetworkList(_ viewModel: DeviceListViewModel?, list: [String])
    func didJoinNetwork(_ uuid: String, model: N2NModel) -> Bool
    func start()
    func stop()
    func showSetting()
    func ping(_ ip: String, _ complete: @escaping (Double) -> Void)
}

class DeviceListViewModel: ObservableObject {
    weak var delegate: DeviceListDelegate?

    @Published var list: [NetworkViewModel] = []
    @Published var host: DeviceInfoViewModel
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var error: DataError = .none
    @Published var isPinging = false
    private var pingCount = 0

    @Published var isStart = false {
        didSet {
            if isStart {
                delegate?.start()
            } else {
                delegate?.stop()
            }
        }
    }

    private let dataStore: DeviceListDataStoreAPI
    private let token: String
    private let user: User
    private var cancellableStore = [AnyCancellable]()

    init(dataStore: DeviceListDataStoreAPI, token: String, user: User) {
        self.dataStore = dataStore
        self.token = token
        self.user = user
        self.host = DeviceInfoViewModel(uuid: user.deviceUUID ?? "null-uuid", name: user.name, ip: "*")
        if let network = user.network {
            host.ip = network.ip
        }
    }

    public func joinNetwork(request: JoinRequest) {
        guard isLoading == false else {
            return
        }
        self.isLoading = true
        dataStore.joinNetwork(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] model in
                self?.host.ip = model.virtual_ip
                if self?.delegate?.didJoinNetwork(request.uuid, model: model) == false {
                    self?.error = DataError.fail(message: "Can't join network")
                }
            })
            .store(in: &cancellableStore)
    }

    func logout() {
        delegate?.logout()
    }

    func ping() {
        guard isPinging == false else {
            return
        }
        isPinging = true
        for subnet in list {
            for device in subnet.list {
                pingCount += 1
                delegate?.ping(device.ip) { [weak self] time in
                    print("ping: \(device.ip), \(time)")
                    self?.objectWillChange.send() //
                    device.ping = Int(time)
                    self?.pingCount -= 1
                    if (self?.pingCount == 0) {
                        self?.isPinging = false
                    }
                }
            }
        }
    }

    func load() {
        guard isLoading == false else {
            return
        }
        self.isLoading = true
        dataStore.fetchNetworkList(NetworkListRequest(token: token))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] model in
                self?.isLoading = false
                let list = self?.parseNetworkList(model: model)
                self?.delegate?.didLoadNetworkList(self, list: list ?? [])
            })
            .store(in: &cancellableStore)
    }

    func showSetting() {
        delegate?.showSetting()
    }

    private func parseNetworkList(model: NetworkListModel) -> [String] {
        for network in model.list {
            var deviceList = [DeviceInfoViewModel]()
            for device in network.devices {
                if let device = device {
                    let deviceViewModel = DeviceInfoViewModel(uuid: device.uuid, name: device.name, ip: device.virtual_ip)
                    deviceList.append(deviceViewModel)
                }
            }
            let networkItem = NetworkViewModel(name: network.name, uuid: network.uuid, list: deviceList)
            list.append(networkItem)
        }
        return model.list.map { $0.uuid }
    }
}

class DeviceInfoViewModel {
    var uuid: String
    var name: String
    var ip: String
    var ping: Int = 0
    init(uuid: String, name: String, ip: String) {
        self.uuid = uuid
        self.name = name
        self.ip = ip
    }
}

class NetworkViewModel {
    var name: String
    var uuid: String
    var list: [DeviceInfoViewModel]

    init(name: String, uuid: String, list: [DeviceInfoViewModel]) {
        self.name = name
        self.uuid = uuid
        self.list = list
    }
}
