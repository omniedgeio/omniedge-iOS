//
//  NetworkListModel.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/6.
//

import Foundation

struct PaginatedResponse<T: Codable>: Codable {
    var meta: [String: AnyCodable]?
    var data: [T]
}

struct NetworkListModel: Codable {
    var data: PaginatedResponse<NetworkModel>
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self.value = x
        } else if let x = try? container.decode(Int.self) {
            self.value = x
        } else if let x = try? container.decode(Double.self) {
            self.value = x
        } else if let x = try? container.decode(String.self) {
            self.value = x
        } else if let x = try? container.decode([String: AnyCodable].self) {
            self.value = x
        } else if let x = try? container.decode([AnyCodable].self) {
            self.value = x
        } else if container.decodeNil() {
            self.value = NSNull()
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for AnyCodable"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let x as Bool:
            try container.encode(x)
        case let x as Int:
            try container.encode(x)
        case let x as Double:
            try container.encode(x)
        case let x as String:
            try container.encode(x)
        case let x as [String: AnyCodable]:
            try container.encode(x)
        case let x as [AnyCodable]:
            try container.encode(x)
        case is NSNull:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}

struct NetworkModel: Codable {
    var name: String
    var id: String
    var ip_range: String
    var devices: [DeviceModel?]
}

struct DeviceListModel: Codable {
    var list: [DeviceModel]
}

struct DeviceModel: Codable {
    var id: String
    var name: String
    var platform: String
    var virtual_ip: String
    var last_seen: String?
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
struct N2NModel: Codable {
    var community_name: String
    var secret_key: String
    var virtual_ip: String
    var subnet_mask: String
    var server: Server

    struct Server: Codable {
        var name: String
        var country: String
        var host: String
    }
}

enum DataError: Error, Hashable {
    case success(message: String)
    case fail(message: String)
    case none
}
