//
//  LoginView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import Foundation
import OEUIKit
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isSecured: Bool = true
    @State private var showConcentAlert: Bool
    @State private var concentChecked = false

    var valid: Bool {
        return !Validation.checkEmailAndPassword(email, password)
    }

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        self.showConcentAlert = !UserDefaults.standard.bool(forKey: "UserConcent")
    }

    public var body: some View {
        ZStack {
            Group {
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
                        AlertView("Login error").onTapGesture {
                            viewModel.error = .none
                        }
                    }
                }
            }.padding()

            /// layer3: loading spinner
            if viewModel.loading {
                //LoadingView()
                ProgressView()
            }
            }.disabled(showConcentAlert)

            if showConcentAlert {
                BottomSheetView(isOpen: .constant(true), maxHeight: 400) {
                    termOfServiceView
                }.shadow(radius: 4)
            }
        } //ZStack
        //.border(Color.black, width: 1)
        .allowsHitTesting(!viewModel.loading)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var termOfServiceView: some View {
        VStack(alignment: .leading) {
            Text("Privacy & Terms").font(.title3.bold())//.padding()
            ScrollView {
            Text("""
Information we collect
The personal information that you are asked to provide, and the reasons why you are asked to provide it, will be made clear to you at the point we ask you to provide your personal information.
    current private info needed: device name
    current privilege: VPN
    Your device's name will be shown in the device list after you join a virtual network.
    VPN will be used to connect your device into a P2P virtual network with you other device.
""").padding()
            }
            //Toggle(isOn: $concentChecked) { Text("") }.padding(.init(top: 0, leading: 0, bottom: 0, trailing: 20)).border(.blue, width: 1)
            HStack(spacing: 0) {
                Text("Our ")
                Link("Term of Service", destination: URL(string: "https://omniedge.io/terms")!)
                Text(" And ")
                Link("Privacy", destination: URL(string: "https://omniedge.io/privacy")!)
            }
            HStack {
                Text("Concent: ")
                Toggle("", isOn: $concentChecked).frame(maxWidth: 60)
                Spacer()
            }

            HStack {
                Button("OK") {
                    self.showConcentAlert = false
                    UserDefaults.standard.setValue(true, forKey: "UserConcent")
                    UserDefaults.standard.synchronize()
                }.disabled(!concentChecked)
                Spacer()
                Button("Quit") {
                    exit(0)
                }
            }
        }.padding()
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
