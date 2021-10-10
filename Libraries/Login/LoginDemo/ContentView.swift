//
//  ContentView.swift
//  LoginDemo
//
//

@testable import Login
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            LoginView(viewModel: LoginViewModel(LoginDataStoreMock()))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
