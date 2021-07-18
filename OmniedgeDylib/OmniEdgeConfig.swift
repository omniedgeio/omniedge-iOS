//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

public struct OmniEdgeConfig : Codable {
    public var superNodeAddr: String
    public var superNodePort: String
    
    public init(defaultHost: String, defaultPort: String) {
        superNodeAddr = defaultHost;
        superNodePort = defaultPort;
        load()
    }
    
    public func sync() {
        let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.meandlife.OminiEdge")?.appendingPathComponent("config.plist")
        guard let file = file else {
            return
        }

        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(self)
            try data.write(to: file)
        } catch {
            print("Couldn't parse file")
        }
    }
    
    private mutating func load() {
        let data: Data
        let file = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.meandlife.OminiEdge")?.appendingPathComponent("config.plist")
        guard let file = file else {
            return
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            print("Couldn't load file")
            return
        }
        
        do {
            let decoder = PropertyListDecoder()
            self = try decoder.decode(OmniEdgeConfig.self, from: data)
        } catch {
            fatalError("Couldn't parse file")
        }
    }
}
