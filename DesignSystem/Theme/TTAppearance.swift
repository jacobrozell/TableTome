import SwiftUI
import UIKit

@MainActor
enum TTAppearance {
    /// Call once at launch, before the first scene renders.
    static func apply() {
        let serifLarge = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(.serif)?
            .withSymbolicTraits(.traitBold)
        let serifInline = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .headline)
            .withDesign(.serif)

        let nav = UINavigationBar.appearance()
        var large = nav.largeTitleTextAttributes ?? [:]
        if let serifLarge { large[.font] = UIFont(descriptor: serifLarge, size: 0) }
        large[.foregroundColor] = UIColor(TTColor.inkPrimary)
        nav.largeTitleTextAttributes = large

        var inline = nav.titleTextAttributes ?? [:]
        if let serifInline { inline[.font] = UIFont(descriptor: serifInline, size: 0) }
        inline[.foregroundColor] = UIColor(TTColor.inkPrimary)
        nav.titleTextAttributes = inline

        if #unavailable(iOS 26.0) {
            let bar = UINavigationBarAppearance()
            bar.configureWithDefaultBackground()
            bar.backgroundColor = UIColor(TTColor.canvas).withAlphaComponent(0.92)
            bar.shadowColor = UIColor(TTColor.stroke)
            bar.largeTitleTextAttributes = large
            bar.titleTextAttributes = inline
            nav.standardAppearance = bar
            nav.scrollEdgeAppearance = {
                let edge = UINavigationBarAppearance()
                edge.configureWithTransparentBackground()
                edge.largeTitleTextAttributes = large
                edge.titleTextAttributes = inline
                return edge
            }()
            nav.compactAppearance = bar

            let tab = UITabBarAppearance()
            tab.configureWithDefaultBackground()
            tab.backgroundColor = UIColor(TTColor.surface).withAlphaComponent(0.94)
            tab.shadowColor = UIColor(TTColor.stroke)
            UITabBar.appearance().standardAppearance = tab
            UITabBar.appearance().scrollEdgeAppearance = tab
        }
        UITabBar.appearance().tintColor = UIColor(TTColor.brandFill)
        UITabBar.appearance().unselectedItemTintColor = UIColor(TTColor.inkTertiary)
    }
}
