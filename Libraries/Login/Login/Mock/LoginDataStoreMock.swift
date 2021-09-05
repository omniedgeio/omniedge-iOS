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
    func login(_ model: LoginModel) -> AnyPublisher<LoginResult, AuthError> {
        let result = LoginResult(message: "Login successfully", data: nil)
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func register(_ model: RegisterModel) -> AnyPublisher<LoginResult, AuthError> {
        let result = LoginResult(message: "Register successfully", data: nil)
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }

    func reset(_ model: ResetPasswordModel) -> AnyPublisher<LoginResult, AuthError> {
        let result = LoginResult(message: "Reset successfully", data: nil)
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    promise(Result.success(result))
                }
            }
        }.eraseToAnyPublisher()
    }
}

#endif //DEBUG
