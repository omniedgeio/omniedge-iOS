//
//  DeviceList.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/13.
//  
//

import OEUIKit
import SwiftUI

struct DeviceList: View {
    var body: some View {
        VStack {
            TextLogo() {
            }
            Spacer()
        }.padding()
    }
}

struct TextLogo: View {
    var action: () -> Void
    var body: some View {
        HStack {
            Image.OME.textLogoIcon.resizable().scaledToFit().frame(width: 40, height: 40)
            Image.OME.textLogoText.resizable().scaledToFit().frame(height: 24)
            Spacer()
            Button(action: {
                action()
            }, label: {
                Image(systemName: "person.crop.circle").resizable().scaledToFit().frame(height: 24).foregroundColor(Color.OME.primary)
            })
        }
    }
}
struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceList()
    }
}
