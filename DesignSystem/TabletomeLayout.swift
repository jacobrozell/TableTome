import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum TabletomeLayoutContext: Equatable, Sendable {
    case phonePortrait
    case phoneLandscape
    case padPortrait
    case padLandscape

    public var isCompactHeight: Bool {
        switch self {
        case .phoneLandscape, .padLandscape: true
        default: false
        }
    }

    public var usesPadSplitNavigation: Bool {
        switch self {
        case .padPortrait, .padLandscape: true
        default: false
        }
    }

    /// iPhone landscape has very little vertical space — collapse decorative chrome during battle.
    public var prefersCollapsedBattleChrome: Bool {
        self == .phoneLandscape
    }
}

public enum TabletomeLayout {
    /// iPhone SE / 8 (667pt) and 13 mini (812pt) portrait heights — extra chrome eats scroll room.
    public static let compactPhoneHeightThreshold: CGFloat = 812

    public enum Idiom: Equatable, Sendable {
        case phone
        case pad
        case other
    }

    @MainActor
    public static func prefersCompactGuidedMatchChrome(
        _ context: TabletomeLayoutContext,
        idiom: Idiom? = nil,
        boundsHeight: CGFloat? = nil
    ) -> Bool {
        switch context {
        case .phoneLandscape:
            true
        case .phonePortrait:
            isCompactPhoneHeight(idiom: idiom, boundsHeight: boundsHeight)
        default:
            false
        }
    }

    @MainActor
    public static func isCompactPhoneHeight(
        idiom: Idiom? = nil,
        boundsHeight: CGFloat? = nil
    ) -> Bool {
        #if canImport(UIKit)
        guard (idiom ?? currentIdiom()) == .phone else { return false }
        let height = boundsHeight ?? UIScreen.main.bounds.height
        return height <= compactPhoneHeightThreshold
        #else
        return false
        #endif
    }

    @MainActor
    public static func currentIdiom() -> Idiom {
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return .phone
        case .pad: return .pad
        default: return .other
        }
        #else
        return .other
        #endif
    }

    @MainActor
    public static func context(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> TabletomeLayoutContext {
        let resolvedIdiom = idiom ?? currentIdiom()
        let compactHeight = verticalSizeClass == .compact
        switch resolvedIdiom {
        case .phone:
            return compactHeight ? .phoneLandscape : .phonePortrait
        case .pad:
            return compactHeight ? .padLandscape : .padPortrait
        case .other:
            if compactHeight { return .padLandscape }
            return horizontalSizeClass == .regular ? .padPortrait : .phonePortrait
        }
    }

    @MainActor
    public static func isPadLandscape(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        context(
            idiom: idiom,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) == .padLandscape
    }

    @MainActor
    public static func isPhone(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        switch context(
            idiom: idiom,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) {
        case .phonePortrait, .phoneLandscape: true
        default: false
        }
    }

    /// iPad and Mac (Designed for iPad) with regular horizontal width.
    @MainActor
    public static func usesLargeScreenLayout(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        guard horizontalSizeClass == .regular else { return false }
        switch idiom ?? currentIdiom() {
        case .pad, .other:
            return true
        case .phone:
            return false
        }
    }

    @MainActor
    public static func usesSideBySideLayout(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        isAccessibilitySize: Bool = false
    ) -> Bool {
        guard !isAccessibilitySize else { return false }
        return usesLargeScreenLayout(idiom: idiom, horizontalSizeClass: horizontalSizeClass)
    }
}

struct TabletomeLayoutReader<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ViewBuilder let content: (_ context: TabletomeLayoutContext) -> Content

    var body: some View {
        content(
            TabletomeLayout.context(
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass
            )
        )
    }
}
