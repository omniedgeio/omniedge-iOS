//
//  LoginDataStoreMock.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/24.
//  
//

import Combine

class LoginDataStoreMock: LoginDataStoreAPI {
    func login(_ model: LoginModel) -> Future<LoginResult, AuthError> {
        let result = LoginResult(message: "Login successfully", data: "hi")
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(Result.success(result))
            }
        }
    }

    func register(_ model: RegisterModel) -> Future<LoginResult, AuthError> {
        let result = LoginResult(message: "Register successfully", data: "hi")
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(Result.success(result))
            }
        }
    }
}
