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
}

#endif //DEBUG
