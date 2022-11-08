//
//  DevicePingProvider.swift
//  DeviceList
//
//  Created by samuelsong on 2022/1/2.
//

import Foundation

class DevicePingProvider: DevicePingAPI {
    func ping(_ ip: String, _ complete: @escaping (Double, Error?) -> Void) {
        // Ping once
        let once = try? SwiftyPing(host: ip, configuration: PingConfiguration(interval: 1.0, with: 3), queue: DispatchQueue.global())
        once?.observer = { (response) in
            var duration = response.duration * 1000.0
            #if false
            if response.error != nil {
                duration = -1
            }
            #endif
            complete(duration, response.error)
        }
        once?.targetCount = 1
        try? once?.startPinging()
    }
}
