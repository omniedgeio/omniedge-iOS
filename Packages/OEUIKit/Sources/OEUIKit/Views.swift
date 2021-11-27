//
//  SwiftUIView.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/30.
//  
//

import SwiftUI

public struct AlertView: View {
    private let message: String
    public init(_ message: String) {
        self.message = message
    }
    public var body: some View {
        HStack {
            Spacer()
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "x.circle")
                    .imageColorAppearance(color: Color.OME.error)
                Text(message)
                    .font(.system(size: 15))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            Spacer()
        }
        .background(Color.OME.error.opacity(0.1))
        .border(Color.OME.error, width: 1)
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

public extension Spacer {
    /// https://stackoverflow.com/a/57416760/3393964
    func forceTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        ZStack {
            Color.black.opacity(0.001).onTapGesture(count: count, perform: action)
            self
        }
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AlertView("The email address and password combination you entered is invalid. Please try again.")
            AlertView("error")
        }
    }
}
