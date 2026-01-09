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
    func didLogin(_ viewModel: LoginViewModel?, token: String, refreshToken: String?)
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

    func login(email: String, password: String, authSessionUUID: String? = nil) {
        guard loading == false else {
            return
        }
        /// clear
        loading = true
        error = .none

        //request
        dataStoreAPI.login(LoginModel(email: email, password: password, auth_session_uuid: authSessionUUID))
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
                if let token = model.token {
                    self?.delegate?.didLogin(self, token: token, refreshToken: model.refreshToken)
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
                if let uuid = model.id {
                    self?.delegate?.didRegisterDevice(self, token: token, deviceUUID: uuid)
                } else {
                    self?.error = .fail(message: "Register Device Error")
                }
            })
            .store(in: &cancellableStore)
    }

    func oauthLogin() {
        guard loading == false else { return }
        let pkce = PKCE.generate()
        let clientId = "omniedge-ios"
        let redirectUri = "io.omniedge:/oauth/callback"
        
        let baseURL = "https://api.omniedge.io/api/v2" // Should ideally come from config
        let authURL = "\(baseURL)/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=code&scope=openid%20profile%20email%20offline_access&state=\(pkce.state)&code_challenge=\(pkce.challenge)&code_challenge_method=S256"
        
        guard let url = URL(string: authURL) else { return }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "io.omniedge") { [weak self] callbackURL, error in
            if let error = error {
                if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    self?.error = .fail(message: error.localizedDescription)
                }
                return
            }
            
            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
                  let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value else {
                return
            }
            
            if returnedState != pkce.state {
                self?.error = .fail(message: "State mismatch")
                return
            }
            
            self?.loading = true
            self?.dataStoreAPI.exchangeOAuthCode(code: code, verifier: pkce.verifier, redirectUri: redirectUri)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] complete in
                    self?.loading = false
                    if case .failure(let error) = complete {
                        self?.error = error
                    }
                }, receiveValue: { [weak self] model in
                    if let token = model.token {
                        self?.delegate?.didLogin(self, token: token, refreshToken: model.refreshToken)
                    }
                })
                .store(in: &(self?.cancellableStore ?? []))
        }
        
        session.presentationContextProvider = self
        session.start()
    }
}

import AuthenticationServices

extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
