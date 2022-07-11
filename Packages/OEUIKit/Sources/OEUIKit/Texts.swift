//
//  File.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/21.
//  
//

import SwiftUI

public extension Text {
    struct OME {
        public static let slogon = { Text("Bring intranet on the internet")
            .font(Font.OME.subTitle)
            .foregroundColor(Color.OME.gray)
        }()
    }
}

struct Texts_Previews: PreviewProvider {
    static var previews: some View {
        Text.OME.slogon.padding()
    }
}
