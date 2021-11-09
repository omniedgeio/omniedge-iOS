//
//  NetworkListModel.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/6.
//

import Foundation

/*
 //list network
 {
     "message": "List virtual network successfully",
     "data": [
         {
             "uuid": "935ab516-8bf3-440a-b32e-002ce3bf7771",
             "name": "My omni network",
             "ip_range": "100.100.0.0/24",
             "role": "admin",
             "devices": []
         }
     ]
 }
 */
struct NetworkListModel {
    var list: [NetworkModel]
}

struct NetworkModel: Decodable {
    var name: String
    var uuid: String
    var ip_range: String
    var role: String
}

struct DeviceListModel {
    var list: [DeviceModel]
}

struct DeviceModel {
    var name: String
}

/*
 //join network
 {
     "message": "Join virtual network successfully",
     "data": {
         "community_name": "20d3a397ecec0f",
         "secret_key": "32bdf7e3cbcbd5",
         "virtual_ip": "100.100.0.81",
         "subnet_mask": "255.255.255.0",
         "server": {
             "name": "China",
             "country": "CN",
             "host": "prod-cn.edgecomputing.network:7787"
         }
     }
 }
 */
struct N2NModel {

}

enum DataError: Error, Hashable {
    case success(message: String)
    case fail(message: String)
    case none
}
