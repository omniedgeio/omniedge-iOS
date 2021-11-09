//
//  DeviceListViewModel.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/8.
//

import Combine

protocol DeviceListDelegate: AnyObject {
    func logout() -> Void
}

class DeviceListViewModel: ObservableObject {
    weak var delegate: DeviceListDelegate?

    @Published var query: String = ""

    func logout() {
        delegate?.logout()
    }
}
