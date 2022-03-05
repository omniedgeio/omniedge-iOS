//
//  DeviceListDataNetwork.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/6.
//

import OENetwork

struct DataNetworkResult: Codable {
    var message: String
    var data: [String: String]?
}

struct DataNetworkListResult: Codable {
    var code: Int?
    var data: [NetworkModel]?
}

struct FetchNetworkListRequst: Request {
    typealias ReturnType = DataNetworkListResult
    var token: String?
    var method = HTTPMethod.get
    var path: String = "/virtual-networks"
}

struct FetchDeviceListRequst: Request {
    typealias ReturnType = DataNetworkResult
    var token: String?
    var method = HTTPMethod.get
    var path: String = "/devices"
}

struct JoinNetworkResult: Codable {
    var data: N2NModel?
}

struct JoinNetworkRequst: Request {
    typealias ReturnType = JoinNetworkResult
    var token: String?
    var uuid: String
    var deviceUUID: String

    var path: String {
        return "/virtual-networks/\(uuid)/devices/\(deviceUUID)/join"
    }
}
