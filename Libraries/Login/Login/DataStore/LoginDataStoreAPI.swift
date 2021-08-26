//
//  LoginDataStoreAPI.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine

protocol LoginDataStoreAPI {
    func login(_ model: LoginModel) -> Future<LoginResult, AuthError>
    func register(_ model: RegisterModel) -> Future<LoginResult, AuthError>
}
