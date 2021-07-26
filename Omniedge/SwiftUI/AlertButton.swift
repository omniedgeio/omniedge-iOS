//
//  AlertButton.swift
//  Omniedge
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/20.
//  
//

import SwiftUI

struct AlertButton: View {
    @State private var showAlert = false

    var text: String
    var title: String
    var message: String?
    var confirm: (() -> Void)?
    var cancel: (() -> Void)?

    var body: some View {
        Button(action: {
            self.showAlert = true
        }) {
            Text(text).foregroundColor(.red)
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text(title),
                message: Text(message ?? ""),
                primaryButton: .destructive(Text("确认"), action: { self.confirm?() }),
                secondaryButton: .cancel(Text("取消"), action: { self.cancel?() })
            )
        }
    }
}
