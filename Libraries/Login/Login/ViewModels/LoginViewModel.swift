//
//  LoginViewModel.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import Combine
import Foundation

protocol LoginDelegate: AnyObject {
    func didLogin(token: String)
    func didRegister(email: String, password: String)
    func didReset(email: String)
}

class LoginViewModel: ObservableObject {
    private var dataStoreAPI: LoginDataStoreAPI
    private var cancellableStore = [AnyCancellable]()
    weak var delegate: LoginDelegate?

    @Published var error: AuthError = AuthError.none

    init(_ dataStore: LoginDataStoreAPI) {
        dataStoreAPI = dataStore
    }

    func login(email: String, password: String) {
        dataStoreAPI.login(LoginModel(email: email, password: password))
            .sink(receiveCompletion: { complete in
                guard self.error == .none else {
                    return
                }
                switch complete {
                case .finished:
                    self.error = .none
                case .failure(let error):
                    self.error = error
                }
            }, receiveValue: { [weak self] model in
                if let token = model.data?["token"] {
                    self?.delegate?.didLogin(token: token)
                } else {
                    self?.error = .fail(message: "Error Token")
                }
            })
            .store(in: &cancellableStore)
    }

    func register(name: String, email: String, password: String) {
        dataStoreAPI.register(RegisterModel(name: name, email: email, password: password))
            .sink(receiveCompletion: { complete in
                guard self.error == .none else {
                    return
                }
                switch complete {
                case .finished:
                    self.error = .none
                case .failure(let error):
                    self.error = error
                }
            }, receiveValue: { [weak self] _ in
                self?.delegate?.didRegister(email: email, password: password)
            })
            .store(in: &cancellableStore)
    }

    func resetPassword(email: String) {
        guard !email.isEmpty else {
            return
        }
        dataStoreAPI.reset(ResetPasswordModel(email: email))
            .sink(receiveCompletion: { complete in
                guard self.error == .none else {
                    return
                }
                switch complete {
                case .finished:
                    self.error = .none
                case .failure(let error):
                    self.error = error
                }
            }, receiveValue: { [weak self] in
                self?.delegate?.didReset(email: email)
            })
            .store(in: &cancellableStore)
    }

    func googleLogin() {
    }

    func isEmailInvalid(email: String) -> Bool {
        return !Validation.checkEmail(email) && !email.isEmpty
    }

    func isPasswordInvalid(password: String) -> Bool {
        return (!Validation.checkPasswordLength(password) || !Validation.checkPasswordCharacterSet(password)) && !password.isEmpty
    }
}
