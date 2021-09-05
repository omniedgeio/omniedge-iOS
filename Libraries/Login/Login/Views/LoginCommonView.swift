//
//  LoginCommonView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/5.
//  
//

import SwiftUI
import OEUIKit

struct GoogleLoginView: View {
    var login: () -> Void
    public var body: some View {
        Button(action: {
            withAnimation {
                login()
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
    }
}

struct LoginCommonView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleLoginView {
        }
    }
}
