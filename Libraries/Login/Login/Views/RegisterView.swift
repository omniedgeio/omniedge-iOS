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
    @ObservedObject var viewModel: RegisterViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var comfirm: String = ""
    @State var isSecured: Bool = true

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        configureBackground()
    }

    public var body: some View {
        ZStack {
            Color.OME.background.onTapGesture {
                hideKeyboard()
            }.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                //Spacer().frame(maxHeight: 40)
                Image.OME.primary
                Text.OME.slogon.padding()

                Button(action: {
                    withAnimation {
                        //self.viewModel.login(email: email, password: password)
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
                }
                .padding(.top, 5)

                createPasswordView("Password", text: $password)
                createPasswordView("Comfirm", text: $comfirm)

                Button(action: {
                    withAnimation {
                        //self.viewModel.login(email: email, password: password)
                    }
                }, label: {
                    Text("Register")
                        .foregroundColor(.white)
                })
                .buttonStyle(PrimaryButtonStyle())
                //.disabled(valid)
                .padding(.top, 30)

                Spacer()
            }.padding()
        }
        //.border(Color.black, width: 1)
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createPasswordView(_ title: LocalizedStringKey, text: Binding<String>) -> some View {
        return ZStack(alignment: .bottomTrailing) {
            if isSecured {
                SecureField(title, text: text)
                    .inputButtonAppearance()
                    .textContentType(.password)
                    .padding(.top, 15)
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: RegisterViewModel(email: "samuel@omniedge.com"))
    }
}
