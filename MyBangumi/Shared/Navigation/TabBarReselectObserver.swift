import SwiftUI
import UIKit

struct TabBarReselectObserver: UIViewControllerRepresentable {
    let observedIndex: Int
    let onReselect: @MainActor () -> Void

    func makeUIViewController(context: Context) -> ObserverViewController {
        let viewController = ObserverViewController()
        viewController.coordinator = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ObserverViewController, context: Context) {
        context.coordinator.observedIndex = observedIndex
        context.coordinator.onReselect = onReselect
        uiViewController.coordinator = context.coordinator
        uiViewController.installIfPossible()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(observedIndex: observedIndex, onReselect: onReselect)
    }

    final class ObserverViewController: UIViewController {
        var coordinator: Coordinator?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            installIfPossible()
        }

        func installIfPossible() {
            guard let tabBarController else { return }
            coordinator?.install(on: tabBarController)
        }
    }

    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var observedIndex: Int
        var onReselect: @MainActor () -> Void
        private weak var tabBarController: UITabBarController?
        private weak var previousDelegate: UITabBarControllerDelegate?

        init(observedIndex: Int, onReselect: @escaping @MainActor () -> Void) {
            self.observedIndex = observedIndex
            self.onReselect = onReselect
        }

        func install(on tabBarController: UITabBarController) {
            guard self.tabBarController !== tabBarController || tabBarController.delegate !== self else { return }
            previousDelegate = tabBarController.delegate
            self.tabBarController = tabBarController
            tabBarController.delegate = self
        }

        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            let targetIndex = tabBarController.viewControllers?.firstIndex(of: viewController)
            if targetIndex == tabBarController.selectedIndex, targetIndex == observedIndex {
                Task { @MainActor in
                    onReselect()
                }
            }
            return previousDelegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            previousDelegate?.tabBarController?(tabBarController, didSelect: viewController)
        }
    }
}
