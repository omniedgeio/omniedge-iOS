//
//  DeviceList+Mock.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/29.
//

#if DEBUG

import Foundation
import OEPlatform

extension User {
    static var mocked: User = User(email: "123@omniedge.com", name: "MyiPhone")
}

#endif
