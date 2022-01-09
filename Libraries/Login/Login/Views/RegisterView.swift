//
//  RegisterView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import OEUIKit
import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: LoginViewModel

    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirm: String = ""
    @State var isSecured: Bool = true

    var invalid: Bool {
        return !Validation.checkEmailAndPassword(email, password) || password != confirm || name.isEmpty
    }

    init(email: String, viewModel: LoginViewModel) {
        self.email = email
        self.viewModel = viewModel
        configureBackground()
    }

    public var body: some View {
        ZStack {
            Color.OME.background.onTapGesture {
                hideKeyboard()
            }.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Group {
                    Image.OME.primary
                    Text.OME.slogon.padding()
                }
                OMEInputField(title: "Name", value: $name, message: "") { _ in
                    return true
                }
                VStack(alignment: .leading) {
                    TextField("Email", text: $email)
                        .inputButtonAppearance()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    if viewModel.isEmailInvalid(email: email) {
                        InvalidEntryView(isInvalid: true, message: "Invalid Email Address")
                    }
                }
                .padding(.top, 5)

                createPasswordView("Password", text: $password)
                if viewModel.isPasswordInvalid(password: password) {
                    InvalidPassword(password: password)
                }
                VStack(alignment: .leading) {
                    createPasswordView("Comfirm", text: $confirm)
                    if !confirm.isEmpty && password != confirm {
                        InvalidEntryView(isInvalid: true, message: "Does not match password")
                    }
                }

                Button(action: {
                    withAnimation {
                        self.viewModel.register(name: name, email: email, password: password)
                    }
                }, label: {
                    Text("Register")
                        .foregroundColor(.white)
                })
                .buttonStyle(PrimaryButtonStyle())
                .disabled(invalid)
                .padding(.top, 30)

                Spacer()
            }.padding()

            //sinner
            if viewModel.loading {
                Spinner.forever
                    .frame(width: 30)
            }
        }
        //.border(Color.black, width: 1)
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createPasswordView(_ title: LocalizedStringKey, text: Binding<String>) -> some View {
        return ZStack(alignment: .bottomTrailing) {
            if isSecured {
                if #available(iOS 15.0, *) {
                    SecureField(title, text: text, prompt: nil)
                        .inputButtonAppearance()
                        .textContentType(.password)
                        .padding(.top, 15)
                } else {
                    SecureField(title, text: text, onCommit: {})
                        .inputButtonAppearance()
                        .textContentType(.password)
                        .padding(.top, 15)
                }
            } else {
                TextField(title, text: text)
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
}

struct OMEInputField: View {
    let title: String
    @Binding var value: String
    let message: String //for invalid
    let validate: (String) -> Bool

    var body: some View {
        VStack(alignment: .leading) {
            TextField(title, text: $value)
                .inputButtonAppearance()
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            if !validate(value) {
                InvalidEntryView(isInvalid: true, message: message)
            }
        }
        .padding(.top, 5)
    }
}

#if DEBUG

struct RegisterView_Previews: PreviewProvider {
    static let dataStore = LoginDataStoreMock()
    static var previews: some View {
        RegisterView(email: "samuel@omniedge.com", viewModel: LoginViewModel(dataStore))
    }
}

#endif
