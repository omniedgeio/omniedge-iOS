//
//  LoginNetworkProvider.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Foundation
import OENetwork
import OEUIKit

struct RegisterRequest: Request {
    typealias ReturnType = LoginResult
    var method: HTTPMethod = .post
    var path: String = "/auth/register"
    var body: [String: Any]?
}
