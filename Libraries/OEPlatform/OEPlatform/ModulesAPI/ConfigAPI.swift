//
//  ConfigAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/22.
//

import Foundation

public struct N2NConfig {
    public var host: String /// server ip
    public var port: String /// server port
    public var networkName: String

    public var ip: String
    public var key: String

    public init(host: String, port: String, networkName: String, ip: String, key: String) {
        self.host = host
        self.port = port
        self.networkName = networkName
        self.ip = ip
        self.key = key
    }
}

public protocol ConfigAPI {
    func save(config: N2NConfig)
}
