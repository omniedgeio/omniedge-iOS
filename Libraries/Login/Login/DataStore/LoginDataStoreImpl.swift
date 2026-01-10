//
//  LoginDataStoreImpl.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine
import OENetwork

class LoginDataStoreProvider: LoginDataStoreAPI {
    private var cancellables = [AnyCancellable]()
    #if false
    private let network = OENetwork(baseURL: "https://dev-api.omniedge.io/api/v2")
    #else
    private let network = OENetwork(baseURL: "https://api.omniedge.io/api/v2")
    #endif

    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(LoginRequest(email: model.email, password: model.password, auth_session_uuid: model.auth_session_uuid))
            .map({ result in
                return LoginResult(token: result.data?.token ?? "",
                                   refreshToken: result.data?.refreshToken ?? "",
                                   expires_at: result.data?.expires_at ?? "")
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func register(_ model: RegisterModel) -> AnyPublisher<RegisterResult, AuthError> {
        return network.dispatch(RegisterRequst(name: model.name, email: model.email, password: model.password))
            .map({ result in
                return RegisterResult(id: result.data?.id)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func reset(_ model: ResetPasswordModel) -> AnyPublisher<ResetResult, AuthError> {
        return network.dispatch(ResetPasswordRequest(email: model.email))
            .map({ result in
                return ResetResult(id: result.data?.status)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func registerDevice(_ token: String) -> AnyPublisher<RegisterDeviceResult, AuthError> {
        return network.dispatch(RegisterDeviceRequest(token: token))
            .map({ result in
                return RegisterDeviceResult(id: result.data?.id)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(OAuthTokenRequest(code: code, verifier: verifier, redirectUri: redirectUri))
            .map({ result in
                return LoginResult(token: result.data?.token ?? "",
                                   refreshToken: result.data?.refreshToken ?? "",
                                   expires_at: result.data?.expires_at ?? "")
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Async Implementation
    func login(_ model: LoginModel) async throws -> LoginResult {
        do {
            let result: LoginNetworkResult = try await network.dispatch(LoginRequest(email: model.email, password: model.password, auth_session_uuid: model.auth_session_uuid))
            return LoginResult(token: result.data?.token ?? "",
                               refreshToken: result.data?.refreshToken ?? "",
                               expires_at: result.data?.expires_at ?? "")
        } catch {
            throw AuthError.fail(message: error.localizedDescription)
        }
    }

    func register(_ model: RegisterModel) async throws -> RegisterResult {
        do {
            let result: RegisterNetworkResult = try await network.dispatch(RegisterRequst(name: model.name, email: model.email, password: model.password))
            return RegisterResult(id: result.data?.id)
        } catch {
            throw AuthError.fail(message: error.localizedDescription)
        }
    }

    func reset(_ model: ResetPasswordModel) async throws -> ResetResult {
        do {
            let result: ResetPasswordNetworkResult = try await network.dispatch(ResetPasswordRequest(email: model.email))
            return ResetResult(id: result.data?.status)
        } catch {
            throw AuthError.fail(message: error.localizedDescription)
        }
    }

    func registerDevice(_ token: String) async throws -> RegisterDeviceResult {
        do {
            let result: RegisterDeviceNetworkResult = try await network.dispatch(RegisterDeviceRequest(token: token))
            return RegisterDeviceResult(id: result.data?.id)
        } catch {
            throw AuthError.fail(message: error.localizedDescription)
        }
    }

    func exchangeOAuthCode(code: String, verifier: String, redirectUri: String) async throws -> LoginResult {
        do {
            let result: LoginNetworkResult = try await network.dispatch(OAuthTokenRequest(code: code, verifier: verifier, redirectUri: redirectUri))
            return LoginResult(token: result.data?.token ?? "",
                               refreshToken: result.data?.refreshToken ?? "",
                               expires_at: result.data?.expires_at ?? "")
        } catch {
            throw AuthError.fail(message: error.localizedDescription)
        }
    }
}
