//
//  DevicePingProvider.swift
//  DeviceList
//
//  Created by samuelsong on 2022/1/2.
//

import Foundation

class DevicePingProvider: DevicePingAPI {
    func ping(_ ip: String, _ complete: @escaping (Double) -> Void) {
        // Ping once
        let once = try? SwiftyPing(host: ip, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        once?.observer = { (response) in
            var duration = response.duration * 1000.0
            if response.error != nil {
                duration = -1
            }
            complete(duration)
        }
        once?.targetCount = 1
        try? once?.startPinging()
    }
}
