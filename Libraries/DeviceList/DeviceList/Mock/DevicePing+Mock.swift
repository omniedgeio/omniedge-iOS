//
//  DevicePing+Mock.swift
//  DeviceList
//
//  Created by samuelsong on 2021/12/26.
//

#if DEBUG

import Tattoo

class DevicePingProviderMock: DevicePingAPI {
    init(scope: APICenter) {}

    func ping(_ ip: String, _ complete: @escaping (Double) -> Void) {
        let delay = Double.random(in: 0..<10)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let time = Double.random(in: 0..<600)
            complete(time)
        }
    }
}

#endif

