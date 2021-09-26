//
//  SwiftUIView.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/5.
//  
//

import SwiftUI

public struct Spinner: View {
    @Binding public var spinning: Bool
    @State private var enable = false

    private var animation: Animation {
        Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    }

    public var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .resizable()
            .aspectRatio( 30.0 / 24.0, contentMode: .fit)
            .rotationEffect(Angle.degrees(spinning && enable ? 360 : 0))
            .animation(spinning ? animation : .default)
            .onAppear(perform: {
                enable = true
            })
            .onDisappear(perform: {
                enable = false
            })
            .frame(minWidth: 12)
    }

    public static var forever: Self {
        .init(spinning: .constant(true))
    }

    public init(spinning: Binding<Bool>) {
        _spinning = spinning
    }
}

public struct LoadingView: View {
    public init() {}
    public var body: some View {
        VStack {
            Rectangle()
                .fill(Color.clear.opacity(0))
                .allowsHitTesting(false)
            Spinner.forever
                .frame(width: 30)
        }
    }
}

struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner.forever
            .frame(width: 60)
            .previewLayout(.fixed(width: 200, height: 100))
    }
}
