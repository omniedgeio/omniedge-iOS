//
//  DeviceListViewModel.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/8.
//

import Combine
import OEPlatform

protocol DeviceListDelegate: AnyObject {
    func logout() -> Void
    func didLoadNetworkList(_ viewModel: DeviceListViewModel?, list: [String])
    func didJoinNetwork(_ uuid: String, model: N2NModel)
    func start()
    func stop()
    func showSetting()
}

class DeviceListViewModel: ObservableObject {
    weak var delegate: DeviceListDelegate?

    @Published var host: DeviceInfoViewModel
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var error: DataError = .none
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
        self.host = DeviceInfoViewModel(name: user.name, ip: "*")
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
                self?.delegate?.didJoinNetwork(request.uuid, model: model)
            })
            .store(in: &cancellableStore)
    }

    func logout() {
        delegate?.logout()
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
        return model.list.map { $0.uuid }
    }
}

struct DeviceInfoViewModel {
    var name: String
    var ip: String
}

struct NetworkViewModel {
    var name: String
    var list: [DeviceInfoViewModel]
}
