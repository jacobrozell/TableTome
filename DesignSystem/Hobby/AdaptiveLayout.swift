import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Shared size-class and Dynamic Type helpers for adaptive navigation and list chrome.
enum AdaptiveLayout {
    /// Two-column split (sidebar + detail) on iPad when horizontal space is regular.
    static func usesSplitNavigation(_ horizontal: UserInterfaceSizeClass?) -> Bool {
        #if canImport(UIKit)
        UIDevice.current.userInterfaceIdiom == .pad && horizontal == .regular
        #else
        horizontal == .regular
        #endif
    }

    /// Sidebar-style list chrome inside a split column on iPad.
    static func usesSidebarListStyle(_ horizontal: UserInterfaceSizeClass?) -> Bool {
        usesSplitNavigation(horizontal)
    }

    /// Wider split column when Dynamic Type is in an accessibility bucket.
    static func splitColumnWidth(dynamicType: DynamicTypeSize) -> (min: CGFloat, ideal: CGFloat, max: CGFloat) {
        if dynamicType.isAccessibilitySize {
            (380, 420, 520)
        } else {
            (320, 380, 440)
        }
    }

    /// Extra bottom inset so empty-state actions clear the tab bar at large Dynamic Type.
    static func tabBarClearance(for dynamicType: DynamicTypeSize) -> CGFloat {
        if dynamicType >= .accessibility5 { return 220 }
        if dynamicType >= .accessibility3 { return 160 }
        if dynamicType.isAccessibilitySize { return 120 }
        return 88
    }

    /// Prefer vertical row layout when text is large or horizontal space is tight.
    static func usesStackedRowLayout(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        dynamicType.isAccessibilitySize || verticalSizeClass == .compact
    }
}

private struct AdaptiveEmptyStateLayout: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let clearance = AdaptiveLayout.tabBarClearance(for: dynamicTypeSize)
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                content
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 8)
                    .padding(.bottom, clearance)
            }
            .scrollBounceBehavior(.basedOnSize)
        } else {
            content.safeAreaPadding(.bottom, clearance)
        }
    }
}

extension View {
    /// Menu-style form pickers often fail to open from sheets (especially inside `NavigationSplitView`).
    func formNavigationPickerStyle() -> some View {
        pickerStyle(.navigationLink)
    }

    /// Scrollable empty states with tab-bar clearance for accessibility text sizes.
    func adaptiveEmptyStateLayout() -> some View {
        modifier(AdaptiveEmptyStateLayout())
    }

    /// Sidebar selection tint for split-view lists; omit on iPhone where `NavigationLink` handles navigation.
    @ViewBuilder
    func listSidebarSelection(isSelected: Bool, enabled: Bool) -> some View {
        if enabled, isSelected {
            listRowBackground(Color.accentColor.opacity(0.12))
        } else {
            self
        }
    }
}
