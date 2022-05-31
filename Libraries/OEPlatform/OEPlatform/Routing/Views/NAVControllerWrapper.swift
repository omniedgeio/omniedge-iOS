import SwiftUI

struct NAVControllerWrapper: UIViewControllerRepresentable {
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
