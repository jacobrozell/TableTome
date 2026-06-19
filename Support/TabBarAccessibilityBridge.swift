import SwiftUI

/// Applies stable accessibility identifiers and visibility to the root `UITabBarController`.
struct TabBarAccessibilityBridge: UIViewControllerRepresentable {
    let itemIdentifiers: [String]
    var isHidden = false

    func makeUIViewController(context: Context) -> Controller {
        Controller(itemIdentifiers: itemIdentifiers, isHidden: isHidden)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.itemIdentifiers = itemIdentifiers
        controller.isHidden = isHidden
        controller.apply()
    }

    final class Controller: UIViewController {
        var itemIdentifiers: [String]
        var isHidden: Bool

        init(itemIdentifiers: [String], isHidden: Bool) {
            self.itemIdentifiers = itemIdentifiers
            self.isHidden = isHidden
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
            applyVisibility(to: tabBarController)
            applyAccessibilityIdentifiers(to: tabBarController)
        }

        private func applyVisibility(to tabBarController: UITabBarController) {
            guard tabBarController.tabBar.isHidden != isHidden else { return }
            tabBarController.tabBar.isHidden = isHidden
            tabBarController.view.setNeedsLayout()
            tabBarController.view.layoutIfNeeded()
        }

        private func applyAccessibilityIdentifiers(to tabBarController: UITabBarController) {
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

/// Keeps iPhone tab bars at the bottom in landscape instead of the iOS 18+ sidebar strip.
struct PhoneTabBarOnlyStyle: ViewModifier {
    func body(content: Content) -> some View {
        if TabletomeLayout.currentIdiom() == .phone {
            content.tabViewStyle(.tabBarOnly)
        } else {
            content
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
