//
//  SettingView.swift
//  DeviceList
//
//  Created by samuelsong on 2021/11/28.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var viewModel: SettingViewModel

    var body: some View {
        List {
            dashBoard
            support
            logout
        }
    }

    @ViewBuilder
    var dashBoard: some View {
        Button(action: {}, label: {
            HStack {
                Image(systemName: "gearshape")
                Text("Dashboard")
            }
        })
    }

    @ViewBuilder
    var support: some View {
        Button(action: {}, label: {
            HStack {
                Image(systemName: "questionmark.circle")
                Text("Support")
            }
        })
    }

    @ViewBuilder
    var logout: some View {
        Button(action: {
            viewModel.logout()
        }, label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                Text("Logout")
            }
        })
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(viewModel: SettingViewModel())
    }
}
