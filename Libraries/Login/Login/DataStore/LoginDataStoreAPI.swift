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
    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) -> AnyPublisher<LoginResult, AuthError>

    // Async equivalents
    func login(_ model: LoginModel) async throws -> LoginResult
    func register(_ model: RegisterModel) async throws -> RegisterResult
    func reset(_ model: ResetPasswordModel) async throws -> ResetResult
    func registerDevice(_ token: String) async throws -> RegisterDeviceResult
    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) async throws -> LoginResult
}
