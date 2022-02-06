//
//  TunnelAPI.swift
//  OEPlatform
//
//  Created by samuelsong on 2021/11/22.
//

import Foundation

public protocol TunnelAPI {
    func start(_ complete: @escaping (Error?) -> Void)
    func stop()
}
