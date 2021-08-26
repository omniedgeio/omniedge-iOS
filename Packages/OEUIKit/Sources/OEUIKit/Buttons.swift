//
//  Button.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/17.
//  
//

import SwiftUI

// MARK: - Public Button Style
public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .modifier(PrimaryButtonStyleModifier(background: Color.OME.primary, foreground: Color.OME.onPrimary, font: Font.OME.buttonPrimary))
            .isPressed(configuration)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(PrimaryButtonStyleModifier(background: Color.white, foreground: Color(.black.withAlphaComponent(0.54)), font: Font.OME.buttonSecondary))
            .isPressed(configuration)
    }
}

// MARK: - Private Modifier
private struct CommonButtonModifier: ViewModifier {
    let font: Font
    init(font: Font) {
        self.font = font
    }
    func body(content: Content) -> some View {
        content
            .font(font)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(14)
    }
}

private struct PrimaryButtonStyleModifier: ViewModifier {
    let background: Color
    let foreground: Color
    let font: Font

    // tracks if the button is enabled or not
    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content
            .modifier(CommonButtonModifier(font: font))
            //.background(Capsule().fill(isEnabled ? background : Color.OME.gray50))
            .background(isEnabled ? background : Color.OME.gray50)
            .cornerRadius(10.0)
            .foregroundColor(isEnabled ? foreground: Color.OME.gray20)
            .shadow(radius: 15)
    }
}

// MARK: - View
private extension View {
    func isPressed(_ configuration: ButtonStyleConfiguration) -> some View {
        self
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

public extension View {
    func configureBackground() {
        let barApperance = UINavigationBarAppearance()
        barApperance.backgroundColor = UIColor(Color.OME.background)
        UINavigationBar.appearance().standardAppearance = barApperance
        UINavigationBar.appearance().scrollEdgeAppearance = barApperance
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZStack {
                Color.OME.background

                VStack {
                    Button(action: {}, label: {
                        Text("PrimaryButtonStyle")
                    })
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()

                    Button(action: {}, label: {
                        Text("PrimaryButtonStyle(disabled)")
                    })
                    .disabled(true)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()

                    //SecondaryButtonStyle
                    Button(action: {}, label: {
                        Text("SecondaryButtonStyle")
                    })
                    .buttonStyle(SecondaryButtonStyle())
                    .padding()
                }
            }
        }
    }
}
