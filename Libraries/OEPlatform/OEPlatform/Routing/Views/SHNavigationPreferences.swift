
import SwiftUI

public struct NAVBarTintColorKey: PreferenceKey {
    public static var defaultValue: Color?

    public static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = nextValue() ?? value
    }
}

public extension View {
    func navigationBarTintColor(_ color: Color?) -> some View {
        self.preference(key: NAVBarTintColorKey.self, value: color)
    }
}
