//
//  InvalidEntryView.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/4.
//  
//

import OEUIKit
import SwiftUI

struct InvalidEntryView: View {
    var isInvalid: Bool
    var message: String
    var body: some View {
        if isInvalid {
            HStack {
                Image(systemName: "x.circle")
                    .imageColorAppearance(color: Color.OME.error)
                Text(message)
                    .font(.system(size: 11))
            }
        } else {
            HStack {
                Image(systemName: "checkmark.circle")
                    .imageColorAppearance(color: Color.OME.successGreen)
                Text(message)
                    .font(.system(size: 11))
            }

        }
    }
}

struct InvalidEntryView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            VStack(alignment: .leading) {
                InvalidEntryView(isInvalid: true, message: "Invalid password")
                InvalidEntryView(isInvalid: false, message: "Good password")
            }
            Spacer()
        }.padding()
    }
}
