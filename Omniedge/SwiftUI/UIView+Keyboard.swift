//
//  UIView+Keyboard.swift
//  Omniedge
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/20.
//  
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
