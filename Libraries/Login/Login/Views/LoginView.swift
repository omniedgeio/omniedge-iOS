//
//  LoginView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import OEUIKit
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isSecured: Bool = true

    var valid: Bool {
        return !Validation.checkEmailAndPassword(email, password)
    }

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            /// layer1: background colorß
            Color.OME.background.onTapGesture {
                hideKeyboard()
            }.edgesIgnoringSafeArea(.all)

            /// layer2: content
            VStack(alignment: .center) {
                Spacer().frame(maxHeight: 40)
                LoginTitleView()
                VStack(alignment: .leading) {
                    if #available(iOS 15.0, *) {
                        TextField("Email", text: $email)
                            .inputButtonAppearance()
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    } else {
                        TextField("Email", text: $email)
                            .inputButtonAppearance()
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    if viewModel.isEmailInvalid(email: email) {
                        InvalidEntryView(isInvalid: true, message: "Invalid Email Address")
                    }

                    ZStack(alignment: .bottomTrailing) {
                        if isSecured {
                            SecureField("Password", text: $password)
                                .inputButtonAppearance()
                                .textContentType(.password)
                                .padding(.top, 15)
                        } else {
                            TextField("Password", text: $password)
                                .inputButtonAppearance()
                                .textContentType(.password)
                                .padding(.top, 15)
                        }
                        Button(action: {
                            isSecured.toggle()
                        }, label: {
                            Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                .accentColor(.gray)
                        })
                        .padding()
                    }
                }
                .padding(.top, 5)

                if viewModel.isPasswordInvalid(password: password) {
                    InvalidPassword(password: password)
                }

                NavigationLink(
                    destination: ResetPasswordView(email: email, viewModel: viewModel),
                    label: {
                        Spacer().forceTapGesture {
                            hideKeyboard()
                        }.frame(maxHeight: 20)
                        Text("Forgot Password")
                            .underline()
                            .font(.system(size: 16))
                            .foregroundColor(Color.OME.slate)
                    })
                    .frame(maxWidth: .infinity)

                Button(action: {
                    withAnimation {
                        hideKeyboard()
                        viewModel.login(email: email, password: password)
                    }}, label: {
                            Text("Sign In")
                                .foregroundColor(.white)
                        })
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(valid)
                        .padding(.top, 30)

                HStack(alignment: .center) {
                    Text("New to OmniEdge?")
                        .font(.system(size: 15))
                    NavigationLink(
                        destination:
                            RegisterView(email: email, viewModel: viewModel),
                        label: {
                            Text("Create an account")
                                .font(.system(size: 15))
                                .foregroundColor(Color.OME.primary)
                        })
                        //.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)

                ZStack {
                    Spacer()
                    if viewModel.error != AuthError.none {
                        AlertView(viewModel.error.localizedDescription).padding()
                    }
                }
            }.padding()

            /// layer3: loading spinner
            if viewModel.loading {
                //LoadingView()
                ProgressView()
            }
        } //ZStack
        //.border(Color.black, width: 1)
        .allowsHitTesting(!viewModel.loading)
        .navigationBarHidden(true)
    }
}

struct InvalidPassword: View {
    let password: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                InvalidEntryView(isInvalid: !Validation.checkPasswordLength(password), message: "At least 8 characters long")
                InvalidEntryView(isInvalid: !Validation.checkPasswordCharacterSet(password), message: "Contains a symbol and number, a lowercase and uppercase")
            }
            Spacer()
        }
    }
}

struct LoginTitleView: View {
    var body: some View {
        Image.OME.primary
        Text.OME.slogon.padding()
    }
}

#if DEBUG

struct LoginView_Previews: PreviewProvider {
    static let dataStore = LoginDataStoreMock()
    static var previews: some View {
        NavigationView {
            LoginView(viewModel: LoginViewModel(dataStore))
        }
    }
}

#endif
