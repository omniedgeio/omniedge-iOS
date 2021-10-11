//
//  NavigationControllerWrapper.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-29.
//

import SwiftUI

/// An internal class used by the platform to wrap a UINavigationController
struct NavigationControllerWrapper: UIViewControllerRepresentable {
    let navigationController: UINavigationController

    func makeCoordinator() -> UINavigationController {
        return navigationController
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        return context.coordinator
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
