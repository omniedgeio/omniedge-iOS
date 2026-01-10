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

class LoginViewModel: NSObject, ObservableObject {
    private var dataStoreAPI: LoginDataStoreAPI
    private var cancellableStore = [AnyCancellable]()
    weak var delegate: LoginDelegate?

    @Published var error: AuthError = AuthError.none
    @Published var loading: Bool = false

    init(_ dataStore: LoginDataStoreAPI) {
        dataStoreAPI = dataStore
    }

    func login(email: String, password: String, authSessionUUID: String? = nil) {
        guard loading == false else { return }
        loading = true
        error = .none

        Task { @MainActor in
            do {
                let model = try await dataStoreAPI.login(LoginModel(email: email, password: password, auth_session_uuid: authSessionUUID))
                if let token = model.token {
                    self.delegate?.didLogin(self, token: token, refreshToken: model.refreshToken)
                } else {
                    self.loading = false
                    self.error = .fail(message: "Error Token")
                }
            } catch let error as AuthError {
                self.error = error
                self.loading = false
            } catch {
                self.error = .fail(message: error.localizedDescription)
                self.loading = false
            }
        }
    }

    func register(name: String, email: String, password: String) {
        self.loading = true
        Task { @MainActor in
            do {
                _ = try await dataStoreAPI.register(RegisterModel(name: name, email: email, password: password))
                self.login(email: email, password: password)
            } catch let error as AuthError {
                self.error = error
                self.loading = false
            } catch {
                self.error = .fail(message: error.localizedDescription)
                self.loading = false
            }
        }
    }

    func resetPassword(email: String) {
        guard !email.isEmpty else { return }
        self.loading = true
        Task { @MainActor in
            do {
                _ = try await dataStoreAPI.reset(ResetPasswordModel(email: email))
                self.loading = false
                self.delegate?.didReset(self, email: email)
            } catch let error as AuthError {
                self.error = error
                self.loading = false
            } catch {
                self.error = .fail(message: error.localizedDescription)
                self.loading = false
            }
        }
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
        Task { @MainActor in
            do {
                let model = try await dataStoreAPI.registerDevice(token)
                self.loading = false
                if let uuid = model.id {
                    self.delegate?.didRegisterDevice(self, token: token, deviceUUID: uuid)
                } else {
                    self.error = .fail(message: "Register Device Error")
                }
            } catch let error as AuthError {
                self.error = error
                self.loading = false
            } catch {
                self.error = .fail(message: error.localizedDescription)
                self.loading = false
            }
        }
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
            Task { @MainActor [weak self] in
                do {
                    let model = try await self?.dataStoreAPI.exchangeOAuthCode(code: code, verifier: pkce.verifier, redirectUri: redirectUri)
                    self?.loading = false
                    if let token = model?.token {
                        self?.delegate?.didLogin(self, token: token, refreshToken: model?.refreshToken)
                    }
                } catch let error as AuthError {
                    self?.error = error
                    self?.loading = false
                } catch {
                    self?.error = .fail(message: error.localizedDescription)
                    self?.loading = false
                }
            }
        }
        
        session.presentationContextProvider = self
        session.start()
    }

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        let token = queryItems.first(where: { $0.name == "token" })?.value
        let refreshToken = queryItems.first(where: { $0.name == "refresh_token" })?.value
        
        if let token = token {
            self.delegate?.didLogin(self, token: token, refreshToken: refreshToken)
        }
    }
}

import AuthenticationServices

extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
