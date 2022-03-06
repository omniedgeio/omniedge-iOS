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
    private let network = OENetwork(baseURL: "https://dev-api.omniedge.io/api/v1")
    #else
    private let network = OENetwork(baseURL: "https://api.omniedge.io/api/v1")
    #endif

    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(LoginRequest(email: model.email, password: model.password))
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
}
