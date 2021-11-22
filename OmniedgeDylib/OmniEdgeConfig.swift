//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

extension OmniEdgeConfig {
    static let group = "group.com.meandlife.Omniedge"

    static let hostKey = "host"
    static let portKey = "port"
    static let networkName = "networkName"
    static let encryptionKey = "encryptionKey"
    static let ipAddress = "ipAddress"
    static let isSecure = "isSecure"
}

public struct OmniEdgeConfig: Codable {
    public var superNodeAddr: String = ""
    public var superNodePort: String = ""
    public var networkName: String = ""
    public var encryptionKey: String = ""
    public var ipAddress: String = ""
    public var isSecure = true

    public init() {
        load()
    }

    public init(host: String, port: String, network: String, key: String, ipAddr: String) {
        superNodeAddr = host
        superNodePort = port
        networkName = network
        encryptionKey = key
        ipAddress = ipAddr
    }

    public func sync() {
        if let dataStorage = UserDefaults(suiteName: OmniEdgeConfig.group) {
            dataStorage.setValue(superNodeAddr, forKey: OmniEdgeConfig.hostKey)
            dataStorage.setValue(superNodePort, forKey: OmniEdgeConfig.portKey)
            dataStorage.setValue(networkName, forKey: OmniEdgeConfig.networkName)
            dataStorage.setValue(encryptionKey, forKey: OmniEdgeConfig.encryptionKey)
            dataStorage.setValue(ipAddress, forKey: OmniEdgeConfig.ipAddress)
            dataStorage.setValue(isSecure, forKey: OmniEdgeConfig.isSecure)
            dataStorage.synchronize()
        }
    }

    private mutating func load() {
        if let dataStorage = UserDefaults(suiteName: OmniEdgeConfig.group) {
            if let host = dataStorage.string(forKey: OmniEdgeConfig.hostKey) {
                superNodeAddr = host
            }

            if let port = dataStorage.string(forKey: OmniEdgeConfig.portKey) {
                superNodePort = port
            }

            if let network = dataStorage.string(forKey: OmniEdgeConfig.networkName) {
                networkName = network
            }
            if let key = dataStorage.string(forKey: OmniEdgeConfig.encryptionKey) {
                encryptionKey = key
            }
            if let ipAddr = dataStorage.string(forKey: OmniEdgeConfig.ipAddress) {
                ipAddress = ipAddr
            }
            isSecure = dataStorage.bool(forKey: OmniEdgeConfig.isSecure)
        }
    }
}
