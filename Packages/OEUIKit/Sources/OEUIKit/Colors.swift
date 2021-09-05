//
//  Color.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/17.
//  
//

import SwiftUI

public extension Color {
    struct OME {
        //foreground
        public static let primary = Color("Primary", bundle: .module)
        public static let gray = Color("Gray", bundle: .module)
        public static let background: Color = Color("Background", bundle: .module)

        public static let label: Color = Color(.label)
        public static let controlBackground: Color = Color("Blue", bundle: .module)
        public static let gray20 = Color("Gray20", bundle: .module)
        public static let gray50 = Color("Gray50", bundle: .module)

        public static let onPrimary = Color("OnPrimary", bundle: .module)
        public static let slate = Color("Slate", bundle: .module)

        public static let error: Color = Color("ErrorRed", bundle: .module)
        public static let successGreen = Color("SuccessGreen", bundle: .module)
    }
}

struct Color_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            Button(action: {}, label: {
                Text("primary")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(14)
            })
            .background(Color.OME.primary)
            .padding()
            //.border(Color.black, width: 1)

            Button(action: {}, label: {
                Text("background")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .padding(14)
            })
            .background(Color.OME.background)
            .padding()
            //.border(Color.black, width: 1)

            Button(action: {}, label: {
                Text("gray")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .padding(14)
            })
            .background(Color.OME.gray)
            .padding()
            //.border(Color.black, width: 1)
        }
    }
}
