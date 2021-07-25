//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

extension OmniEdgeConfig {
    static let group = "group.com.meandlife.OminiEdge"
    static let networkName = "networkName"
    static let encryptionKey = "encryptionKey"
    static let ipAddress = "ipAddress"
    static let isSecure = "isSecure"
}

public struct OmniEdgeConfig : Codable {
    public var superNodeAddr: String = "54.223.23.92"
    public var superNodePort: String = "7787"
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
            } else {
                networkName = "mynetwork"
            }
            
            if let key = dataStorage.string(forKey: OmniEdgeConfig.encryptionKey) {
                encryptionKey = key
            } else {
                encryptionKey = "mysecretpass"
            }
            
            if let ip = dataStorage.string(forKey: OmniEdgeConfig.ipAddress) {
                ipAddress = ip
            } else {
                ipAddress = "10.254.1.123"
            }
            
            isSecure = dataStorage.bool(forKey: OmniEdgeConfig.isSecure)
        }
    }
}
