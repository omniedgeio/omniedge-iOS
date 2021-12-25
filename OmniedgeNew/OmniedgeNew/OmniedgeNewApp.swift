//
//  OmniedgeNewApp.swift
//  OmniedgeNew
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/8/14.
//  
//

import SwiftUI
import Tattoo

@main
struct OmniedgeNewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            appDelegate.appCoordinator.contentView.ignoresSafeArea().navigationBarHidden(true)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private let appScope = Scope()
    let appCoordinator: AppCoordinator

    override init() {
        appCoordinator = AppCoordinator(scope: appScope)
        super.init()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        appCoordinator.bootstrap(scope: appScope)
        return true
    }
}
