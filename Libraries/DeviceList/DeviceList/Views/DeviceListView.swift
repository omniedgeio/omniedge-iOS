//
//  DeviceList.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/13.
//  
//

import Combine
import OEPlatform
import OEUIKit
import SwiftUI

public struct DeviceListView: View {
    @ObservedObject var viewModel: DeviceListViewModel

    public var body: some View {
        ZStack {
            Color.OME.background.onTapGesture {
                hideKeyboard()
            }.edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                TextLogo {
                    viewModel.showSetting()
                }
                OMESearchBar(placeholder: "Search", searchQuery: $viewModel.query).cornerRadius(10)
                hostDeviceInfoView
                    .background(Color.white)
                    .cornerRadius(10)

                Button(action: {
                    viewModel.logout()
                }, label: {
                    Text("Ping Device")
                }).buttonStyle(TertiaryButtonStyle())

                deviceListView()
                    .background(Color.clear)
                    .cornerRadius(10)
                Spacer()
            }.padding()

            if viewModel.isLoading {
                ProgressView()
            }

            if viewModel.error != DataError.none {
                AlertView(viewModel.error.localizedDescription).padding()
            }
        }.onAppear {
            viewModel.load()
        }.allowsHitTesting(!viewModel.isLoading)
    }

    @ViewBuilder
    var hostDeviceInfoView: some View {
        HStack {
            deviceInfoView(info: viewModel.host)
            Toggle(isOn: $viewModel.isStart, label: {
            })
        }.padding(.trailing, 8)
    }

    @ViewBuilder
    func deviceListView() -> some View {
        List {
            ForEach(viewModel.list, id: \.uuid) { network in
                Section(header: Text(network.name).font(Font.OME.subTitle12)) {
                    ForEach(network.list, id: \.uuid) { device in
                        normalDeviceInfoView(info: device)
                    }
                }.textCase(.none)
            }
        }.listStyle(GroupedListStyle())
    }

    @ViewBuilder
    private func normalDeviceInfoView(info: DeviceInfoViewModel) -> some View {
        HStack(alignment: .bottom) {
            deviceInfoView(info: info)
            Spacer()
            Text("\(info.ping) ms")
        }.padding(.trailing, 8)
    }

    @ViewBuilder
    private func deviceInfoView(info: DeviceInfoViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(info.name).font(Font.OME.subTitle17)
            HStack(spacing: 8) {
                Text(info.ip)
                    .font(Font.OME.subTitle17.semibold())
                    .foregroundColor(Color.OME.gray60)
                Image(systemName: "flag.fill").imageColorAppearance(color: Color.red)
            }
        }
        .padding(8)
    }
}

struct TextLogo: View {
    var action: () -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image.OME.textLogoIcon.resizable().scaledToFit().frame(width: 32, height: 37)
            Image.OME.textLogoText.resizable().scaledToFit().frame(height: 22)
            Spacer()
            Button(action: {
                action()
            }, label: {
                Image(systemName: "person.crop.circle").resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(Color.OME.primary)
            })
        }
    }
}

#if DEBUG

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(viewModel: DeviceListViewModel(dataStore: DeviceListDataProvider(), token: "", user: User.mocked))
    }
}

#endif
