//
//  SHNavigationPreferences.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-04-26.
//

import SwiftUI

/// A prefernce key used to modify the navigation bar tint color
///
/// - note: This is in BETA and might be removed as it's not reliable
public struct NavigationBarTintColorKey: PreferenceKey {
    public static var defaultValue: Color?

    public static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = nextValue() ?? value
    }
}

public extension View {
    /// Sets the preferred navigation bar tint color
    ///
    /// - note: This is in BETA and might be removed as it's not reliable
    func navigationBarTintColor(_ color: Color?) -> some View {
        self.preference(key: NavigationBarTintColorKey.self, value: color)
    }
}
