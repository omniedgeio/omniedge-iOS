//
//  LoginDataStoreMock.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine

#if DEBUG

class LoginDataStoreMock: LoginDataStoreAPI {
    func registerDevice(_ token: String) -> AnyPublisher<RegisterDeviceResult, AuthError> {
        let result = RegisterDeviceResult(id: "sfsd")
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError> {
        let result = LoginResult(token: "sdufifjsf&6sfsSFsljfsdlkj112@3kjflj", refreshToken: "123", expires_at: "34")
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func register(_ model: RegisterModel) -> AnyPublisher<RegisterResult, AuthError> {
        let result = RegisterResult(id: "234")
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func reset(_ model: ResetPasswordModel) -> AnyPublisher<ResetResult, AuthError> {
        let result = ResetResult(id: "sfs")
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) -> AnyPublisher<LoginResult, AuthError> {
        let result = LoginResult(token: "oauth_token", refreshToken: "refresh", expires_at: "3600")
        return Just(result).setFailureType(to: AuthError.self).eraseToAnyPublisher()
    }

    // MARK: - Async methods
    func login(_ model: LoginModel) async throws -> LoginResult {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return LoginResult(token: "sdufifjsf&6sfsSFsljfsdlkj112@3kjflj", refreshToken: "123", expires_at: "34")
    }

    func register(_ model: RegisterModel) async throws -> RegisterResult {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return RegisterResult(id: "234")
    }

    func reset(_ model: ResetPasswordModel) async throws -> ResetResult {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return ResetResult(id: "sfs")
    }

    func registerDevice(_ token: String) async throws -> RegisterDeviceResult {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        return RegisterDeviceResult(id: "sfsd")
    }

    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) async throws -> LoginResult {
        return LoginResult(token: "oauth_token", refreshToken: "refresh", expires_at: "3600")
    }
}

#endif //DEBUG
