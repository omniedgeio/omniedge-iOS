//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

public class OmniEdgeConfig {
    public var superNodeAddr: String;
    public var superNodePort: String
    public init(addr: String, port: String) {
        superNodeAddr = addr;
        superNodePort = port;
    }
}
