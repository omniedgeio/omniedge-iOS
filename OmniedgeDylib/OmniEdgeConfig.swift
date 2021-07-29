//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

extension OmniEdgeConfig {
    static let group = "group.com.meandlife.Omniedge"
    static let networkName = "networkName"
    static let encryptionKey = "encryptionKey"
    static let ipAddress = "ipAddress"
    static let isSecure = "isSecure"
}

public struct OmniEdgeConfig : Codable {
    public var superNodeAddr: String = ""
    public var superNodePort: String = ""
    public var networkName: String = ""
    public var encryptionKey: String = ""
    public var ipAddress: String = ""
    public var isSecure = true
    
    public init() {
        load()
    }
    
    public init(network: String, key: String, ip: String) {
        networkName = network
        encryptionKey = key
        ipAddress = ip
        load()
    }
    
    public func sync() {
        if let dataStorage = UserDefaults.init(suiteName: OmniEdgeConfig.group) {
            dataStorage.setValue(networkName, forKey: OmniEdgeConfig.networkName)
            dataStorage.setValue(encryptionKey, forKey: OmniEdgeConfig.encryptionKey)
            dataStorage.setValue(ipAddress, forKey: OmniEdgeConfig.ipAddress)
            dataStorage.setValue(isSecure, forKey: OmniEdgeConfig.isSecure)
            dataStorage.synchronize()
        }
    }
    
    private mutating func load() {
        if let dataStorage = UserDefaults.init(suiteName: OmniEdgeConfig.group) {
            if let network = dataStorage.string(forKey: OmniEdgeConfig.networkName) {
                networkName = network
            }
            if let key = dataStorage.string(forKey: OmniEdgeConfig.encryptionKey) {
                encryptionKey = key
            }
            if let ip = dataStorage.string(forKey: OmniEdgeConfig.ipAddress) {
                ipAddress = ip
            }
            isSecure = dataStorage.bool(forKey: OmniEdgeConfig.isSecure)
        }
    }
}
