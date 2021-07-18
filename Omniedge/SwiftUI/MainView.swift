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
        MainViewModel(config: .init(addr: "54.223.23.92", port: "7787"))

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    HStack(alignment: .center) {
                        Text("Host").font(.callout)
                        TextField("Host", text: $viewModel.config.superNodeAddr)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .center) {
                        Text("Port").font(.callout)
                        TextField("Port", text: $viewModel.config.superNodePort)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Status")) {
                    Text("Status: ") + Text(viewModel.status.rawValue)
                    if viewModel.status == .off || viewModel.status == .invalid {
                        Button(action: {
                            self.hideKeyboard()
                            self.viewModel.handleStart()
                        }) {
                            Text("Start")
                        }
                    } else {
                        Button(action: {
                            self.hideKeyboard()
                            self.viewModel.handleStop()
                        }) {
                            Text("Stop")
                        }
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
            .navigationBarTitle("VPN Status")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
