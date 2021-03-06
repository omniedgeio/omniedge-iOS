//
//  LoginDataStoreAPI.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine

protocol LoginDataStoreAPI {
    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError>
    func register(_ model: RegisterModel) -> AnyPublisher<RegisterResult, AuthError>
    func reset(_ model: ResetPasswordModel) -> AnyPublisher<ResetResult, AuthError>
    func registerDevice(_ token: String) -> AnyPublisher<RegisterDeviceResult, AuthError>
}
