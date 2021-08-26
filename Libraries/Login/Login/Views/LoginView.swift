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

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.OME.background.onTapGesture {
                hideKeyboard()
            }.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer().frame(maxHeight: 40)
                Image.OME.primary
                Text.OME.slogon.padding()

                Button(action: {
                    withAnimation {
                        viewModel.login(email: email, password: password)
                    }
                }, label: {
                    HStack {
                        Image.OME.google
                        Spacer().frame(width: 20)
                        Text("Continue with Google")
                            .foregroundColor(Color(.black.withAlphaComponent(0.54)))
                            .font(Font.OME.buttonSecondary)
                    }
                })
                .buttonStyle(SecondaryButtonStyle())
                //.disabled(valid)
                .padding(.top, 5)

                Text("- or continue with email -")
                    .font(Font.OME.subTitle)
                    .foregroundColor(Color.OME.gray)
                VStack(alignment: .leading) {
                    TextField("Email", text: $email)
                        .inputButtonAppearance()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)

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

                NavigationLink(
                    destination: ResetPasswordView(viewModel: ResetPasswordViewModel("samuel@omniedge.com")),
                    label: {
                        Spacer()
                        Text("Forgot Password")
                            .underline()
                            .font(.system(size: 16))
                            .foregroundColor(Color.OME.slate)
                    })
                    .frame(maxWidth: .infinity)

                Button(action: {
                    withAnimation {
                        //self.viewModel.login(email: email, password: password)
                    }
                }, label: {
                    Text("Sign In")
                        .foregroundColor(.white)
                })
                .buttonStyle(PrimaryButtonStyle())
                //.disabled(valid)
                .padding(.top, 30)

                HStack(alignment: .center) {
                    Text("New to OmniEdge?")
                        .font(.system(size: 15))
                    NavigationLink(
                        destination:
                            RegisterView(viewModel: RegisterViewModel(email: "samuel@omniedge.com")),
                        label: {
                            Text("Create an account")
                                .font(.system(size: 15))
                                .foregroundColor(Color.OME.primary)
                        })
                        //.frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)

                Spacer()
            }.padding()
        }
        //.border(Color.black, width: 1)
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static let dataStore = LoginDataStoreMock()
    static var previews: some View {
        NavigationView {
            LoginView(viewModel: LoginViewModel(dataStore))
        }
    }
}
