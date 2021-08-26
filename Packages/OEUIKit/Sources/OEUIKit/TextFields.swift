//
//  Inputs.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/19.
//  
//

import SwiftUI

// MARK: - Public
public extension View {
    func inputButtonAppearance() -> some View {
        self.modifier(ButtonAppearance())
    }

    func signUpButtonAppearance() -> some View {
        self.modifier(ContinueButtonAppearance())
    }
}

#if canImport(UIKit)
public extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}
#endif

// MARK: - Private
//customised modifier for input buttons
private struct ButtonAppearance: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .autocapitalization(.none)
            .frame(height: 48.0)
            .background(Color(red: 239 / 255, green: 243 / 255, blue: 244 / 255))
            .font(Font.system(size: 15, weight: .medium))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

//customised modifier for continue buttons
private struct ContinueButtonAppearance: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(Font.system(size: 18))
            .frame(maxWidth: .infinity, minHeight: 48.0)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    @State static var email: String = ""
    static var previews: some View {
        VStack {
            TextField("Email", text: $email)
                .inputButtonAppearance()
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
        }
    }
}
