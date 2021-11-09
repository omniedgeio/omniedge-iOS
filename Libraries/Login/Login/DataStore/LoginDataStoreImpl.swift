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
    private let network = OENetwork(baseURL: "https://dev.omniedge.io/api")

    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(LoginRequest(email: model.email, password: model.password))
            .map({ result in
                return LoginResult(message: result.message, data: result.data)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func register(_ model: RegisterModel) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(RegisterRequst(name: model.name, email: model.email, password: model.password))
            .map({ result in
                return LoginResult(message: result.message, data: result.data)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func reset(_ model: ResetPasswordModel) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(ResetPasswordRequest(email: model.email))
            .map({ result in
                return LoginResult(message: result.message, data: result.data)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func registerDevice(_ token: String) -> AnyPublisher<LoginResult, AuthError> {
        return network.dispatch(RegisterDeviceRequest(token: token))
            .map({ result in
                return LoginResult(message: result.message, data: result.data)
            })
            .mapError { error in
                return AuthError.fail(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
