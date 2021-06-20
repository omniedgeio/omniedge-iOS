//
//  OmniEdgeConfig.swift
//  Tunnel
//
//  Created by samuel.song.bc@gmail.com on 2021/5/24.
//

import Foundation

class OmniEdgeConfig {
    var superNodeAddr: String;
    var superNodePort: String
    init(addr: String, port: String) {
        superNodeAddr = addr;
        superNodePort = port;
    }
}
