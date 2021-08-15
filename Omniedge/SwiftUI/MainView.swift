//
//  MainView.swift
//  Omniedge
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/6/20.
//  
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel =
        MainViewModel(config: .init(network: "mynetwork", key: "mysecretpass", ipAddr: "10.254.1.123"))

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    HStack(alignment: .center) {
                        Text("Server IP").font(.callout)
                        TextField("192.168.0.23", text: $viewModel.config.superNodeAddr)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .center) {
                        Text("Server Port").font(.callout)
                        TextField("7787", text: $viewModel.config.superNodePort)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .center) {
                        Text("Network name").font(.callout)
                        TextField("mynetwork", text: $viewModel.config.networkName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .center) {
                        Text("IP").font(.callout)
                        TextField("IP", text: $viewModel.config.ipAddress)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .center) {
                        Text("Encryption key").font(.callout)
                        if viewModel.config.isSecure {
                        SecureField("mysecretpass", text: $viewModel.config.encryptionKey)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                        } else {
                            TextField("mysecretpass", text: $viewModel.config.encryptionKey)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.gray)

                        }
                        Button(action: {
                            viewModel.config.isSecure.toggle()
                        }, label: {
                            Image(systemName: viewModel.config.isSecure ? "eye.slash" : "eye").accentColor(viewModel.config.isSecure ? .gray : nil)
                        })
                    }
                }

                Section(header: Text("Status")) {
                    Text("Status: ") + Text(viewModel.status.text)
                    if viewModel.status == .offline || viewModel.status == .invalid {
                        Button(action: {
                            self.hideKeyboard()
                            self.viewModel.handleStart()
                        }, label: {
                            Text("Start")
                        })
                    } else {
                        Button(action: {
                            self.hideKeyboard()
                            self.viewModel.handleStop()
                        }, label: {
                            Text("Stop")
                        })
                    }
                }
                Section {
                    AlertButton(text: "Remove",
                                title: "确定删除?",
                                message: nil,
                                confirm: {
                                      self.viewModel.handleRemove()
                                },
                                cancel: nil)
                }
            }
            .navigationBarTitle("Omniedge")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Network Error"),
                dismissButton: .destructive(Text("OK"), action: nil))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
