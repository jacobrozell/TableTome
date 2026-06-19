import SwiftUI

/// Applies stable accessibility identifiers to `UITabBar` items for UI automation.
struct TabBarAccessibilityBridge: UIViewControllerRepresentable {
    let itemIdentifiers: [String]

    func makeUIViewController(context: Context) -> Controller {
        Controller(itemIdentifiers: itemIdentifiers)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.itemIdentifiers = itemIdentifiers
        controller.apply()
    }

    final class Controller: UIViewController {
        var itemIdentifiers: [String]

        init(itemIdentifiers: [String]) {
            self.itemIdentifiers = itemIdentifiers
            super.init(nibName: nil, bundle: nil)
            view.isHidden = true
            view.isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            apply()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            apply()
        }

        func apply() {
            guard let tabBarController = tabBarController() else { return }
            let items = tabBarController.tabBar.items ?? []
            for (index, identifier) in itemIdentifiers.enumerated() where index < items.count {
                items[index].accessibilityIdentifier = identifier
            }

            let buttons = tabBarController.tabBar.subviews
                .filter { NSStringFromClass(type(of: $0)).contains("Button") }
                .sorted { $0.frame.minX < $1.frame.minX }
            for (index, identifier) in itemIdentifiers.enumerated() where index < buttons.count {
                buttons[index].accessibilityIdentifier = identifier
            }
        }

        private func tabBarController() -> UITabBarController? {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
                return nil
            }
            return root.findTabBarController()
        }
    }
}

private extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let tabBar = self as? UITabBarController { return tabBar }
        for child in children {
            if let tabBar = child.findTabBarController() { return tabBar }
        }
        return presentedViewController?.findTabBarController()
    }
}
