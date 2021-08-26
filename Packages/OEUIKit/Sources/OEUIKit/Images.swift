//
//  SwiftUIView.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/19.
//  
//

import SwiftUI

public extension Image {
    struct OME {
        public static let primary = Image("PrimaryIcon", bundle: .module)
        public static let google = Image("Google", bundle: .module)
    }
}

struct Images_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Primary Icon")
                .padding()
            Image.OME.primary
            Text("Google")
            Image.OME.google
        }
    }
}
