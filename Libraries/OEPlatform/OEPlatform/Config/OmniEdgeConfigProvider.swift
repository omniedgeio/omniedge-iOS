//
//  OmniEdgeConfigProvider.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/22.
//

import Foundation
import OmniedgeDylib
import Tattoo

public class OmniEdgeConfigProvider: ConfigAPI {
    public init(scope: Scope) {}
    public func save(config: N2NConfig) {
        let writter = OmniEdgeConfig(host: config.host, port: config.port, network: config.networkName, key: config.key, ipAddr: config.ip)
        writter.sync()
    }
}
