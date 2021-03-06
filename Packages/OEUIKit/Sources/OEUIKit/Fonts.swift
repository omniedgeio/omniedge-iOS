//
//  File.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/18.
//  
//

import SwiftUI

public extension UIFont {
    class OME {
        public static let buttonPrimary = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 20.0, weight: .bold))
        public static let buttonSecondary = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 20, weight: .medium))
        public static let buttonTertiary = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold))

        public static let subTitle = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        public static let subTitle12 = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .bold))
        public static let subTitle17 = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.systemFont(ofSize: 17, weight: .bold))
        public static let subTitle25 = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.systemFont(ofSize: 25, weight: .bold))
    }
}
public extension Font {
    struct OME {
        public static let buttonPrimary: Font = Font(UIFont.OME.buttonPrimary)
        public static let buttonSecondary: Font = Font(UIFont.OME.buttonSecondary)
        public static let buttonTertiary: Font = Font(UIFont.OME.buttonTertiary)
        public static let subTitle: Font = Font(UIFont.OME.subTitle)
        public static let subTitle12: Font = Font(UIFont.OME.subTitle12)
        public static let subTitle17: Font = Font(UIFont.OME.subTitle17)
        public static let subTitle25: Font = Font(UIFont.OME.subTitle25)
    }
}

extension Font {
    public func semibold() -> Font {
        self.weight(.semibold)
    }

    public func medium() -> Font {
        self.weight(.medium)
    }
}

struct Fonts_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Font: buttonPrimary")
                .font(Font.OME.buttonPrimary)
                .padding()
            Text("Font: buttonPrimary")
                .font(Font.OME.buttonPrimary)
                .foregroundColor(.white)
                .background(Color.OME.primary)
                .padding()
            Text("Font: buttonSecondary")
                .font(Font.OME.buttonSecondary)
                .padding()
            Text("Font: buttonSecondary")
                .font(Font.OME.buttonSecondary)
                .foregroundColor(.white)
                .background(Color.OME.primary)
                .padding()
            Text("Font: subTitle")
                .font(Font.OME.subTitle)
                .foregroundColor(Color.OME.gray)
                .background(Color.OME.background)
                .padding()
        }
    }
}
