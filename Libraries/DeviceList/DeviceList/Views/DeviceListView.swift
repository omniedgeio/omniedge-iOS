//
//  DeviceList.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/13.
//  
//

import Combine
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
                    viewModel.logout()
                }
                OMESearchBar(placeholder: "Search", searchQuery: $viewModel.query).cornerRadius(10)

                HostDeviceInfoView()
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
        }
    }

    @ViewBuilder
    func deviceListView() -> some View {
        List {
            Section(header: Text("OmniEdge US").font(Font.OME.subTitle12)) {
                NormalDeviceInfoView()
                DeviceInfoView()
            }.textCase(.none)

            Section(header: Text("OmniEdge Malaysia").font(Font.OME.subTitle12)) {
                DeviceInfoView()
                DeviceInfoView()
                DeviceInfoView()
                DeviceInfoView()
            }.textCase(.none)
        }.listStyle(GroupedListStyle())
    }
}

struct NormalDeviceInfoView: View {
    @State var isStart = false
    var body: some View {
        HStack(alignment: .bottom) {
            DeviceInfoView()
            Spacer()
            Text("3 ms")
        }.padding(.trailing, 8)
    }
}

struct HostDeviceInfoView: View {
    @State var isStart = false
    var body: some View {
        HStack {
            DeviceInfoView()
            Toggle(isOn: $isStart, label: {
            })
        }.padding(.trailing, 8)
    }
}

struct DeviceInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Yong's iPhone").font(Font.OME.subTitle17)
            HStack(spacing: 8) {
                Text("100.195.112.123")
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

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView(viewModel: DeviceListViewModel())
    }
}
