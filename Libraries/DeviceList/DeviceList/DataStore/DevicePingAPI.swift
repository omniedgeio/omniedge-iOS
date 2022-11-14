//
//  DevicePingAPI.swift
//  DeviceList
//
//  Created by samuelsong on 2021/12/26.
//

import Foundation

protocol DevicePingAPI: AnyObject {
    func ping(_ ip: String, _ complete: @escaping (Double, Error?) -> Void)
}
