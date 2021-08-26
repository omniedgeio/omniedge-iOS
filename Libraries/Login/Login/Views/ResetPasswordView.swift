//
//  ForgetPasswordView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/16.
//  
//

import OEUIKit
import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var viewModel: ResetPasswordViewModel
    @State var email: String = ""
    @State var password: String = ""
    @State var isSecured: Bool = true

    init(viewModel: ResetPasswordViewModel) {
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
                Text("- forget passowrd -")
                    .font(Font.OME.subTitle25)
                    .foregroundColor(Color.OME.primary)
                    .padding()
                VStack(alignment: .leading) {
                    TextField("Email", text: $email)
                        .inputButtonAppearance()
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                .padding(.top, 5)

                Button(action: {
                    withAnimation {
                        //self.viewModel.login(email: email, password: password)
                    }
                }, label: {
                    Text("Send Instruction")
                        .foregroundColor(.white)
                })
                .buttonStyle(PrimaryButtonStyle())
                //.disabled(valid)
                .padding(.top, 30)
                Spacer()
            }.padding()
        }
        //.border(Color.black, width: 1)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ForgetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: ResetPasswordViewModel("samuel@omniedge.com"))
    }
}
