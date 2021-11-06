//
//  File.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine
import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol Request {
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var contentType: String { get }
    var body: [String: Any]? { get }
    associatedtype ReturnType: Codable
}

// MARK: - Default For Protocl
public extension Request {
    static var commonHeaders: [String: String]? {
        return ["User-Agent": "OmniEdge iOS", "Accept": "*/*", "Content-Type": "application/json"]
    }

    static func bearToken(_ token: String) -> [String: String] {
        return ["Authorization": "Bearer \(token)"]
    }

    var method: HTTPMethod { return .post } //default POST
    var headers: [String: String]? {
        return Self.commonHeaders
    }
    var contentType: String { return "application/json" }
    var body: [String: Any]? { return nil }
}

// MARK: - Private
extension Request {
    private func requestBodyFrom(_ body: [String: Any]?) -> Data? {
        guard let body = body else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            return nil
        }
        return httpBody
    }
    func asURLRequest(baseURL: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = "\(urlComponents.path)\(path)"
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(body)
        request.allHTTPHeaderFields = headers
        return request
    }
}
