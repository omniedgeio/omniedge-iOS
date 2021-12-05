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
    func didLogin(_ viewModel: LoginViewModel?, token: String)
    func didReset(_ viewModel: LoginViewModel?, email: String)
    func didRegisterDevice(_ viewModel: LoginViewModel?, token: String, deviceUUID: String)
}

class LoginViewModel: ObservableObject {
    private var dataStoreAPI: LoginDataStoreAPI
    private var cancellableStore = [AnyCancellable]()
    weak var delegate: LoginDelegate?

    @Published var error: AuthError = AuthError.none
    @Published var loading: Bool = false

    init(_ dataStore: LoginDataStoreAPI) {
        dataStoreAPI = dataStore
    }

    func login(email: String, password: String) {
        guard loading == false else {
            return
        }
        /// clear
        loading = true
        error = .none

        //request
        dataStoreAPI.login(LoginModel(email: email, password: password))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                    self?.loading = false
                }
            }, receiveValue: { [weak self] model in
                if let token = model.data?["token"] {
                    self?.delegate?.didLogin(self, token: token)
                } else {
                    self?.loading = false
                    self?.error = .fail(message: "Error Token")
                }
            })
            .store(in: &cancellableStore)
    }

    func register(name: String, email: String, password: String) {
        self.loading = true
        dataStoreAPI.register(RegisterModel(name: name, email: email, password: password))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                self?.loading = false
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                }
            }, receiveValue: { [weak self] _ in
                self?.loading = false
                self?.login(email: email, password: password)
            })
            .store(in: &cancellableStore)
    }

    func resetPassword(email: String) {
        guard !email.isEmpty else {
            return
        }
        self.loading = true
        dataStoreAPI.reset(ResetPasswordModel(email: email))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                self?.loading = false
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                }
            }, receiveValue: { [weak self] _ in
                self?.delegate?.didReset(self, email: email)
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

    public func registerDevice(_ token: String) {
        dataStoreAPI.registerDevice(token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] complete in
                self?.loading = false
                switch complete {
                case .finished:
                    self?.error = .none
                case .failure(let error):
                    self?.error = error
                }
            }, receiveValue: { [weak self] model in
                if let uuid = model.data?["uuid"] {
                    self?.delegate?.didRegisterDevice(self, token: token, deviceUUID: uuid)
                } else {
                    self?.error = .fail(message: "Register Device Error")
                }
            })
            .store(in: &cancellableStore)
    }
}
