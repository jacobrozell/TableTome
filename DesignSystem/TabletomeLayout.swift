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
}

public enum TabletomeLayout {
    public enum Idiom: Equatable, Sendable {
        case phone
        case pad
        case other
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

    @MainActor
    public static func usesSideBySideLayout(
        idiom: Idiom? = nil,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        isAccessibilitySize: Bool = false
    ) -> Bool {
        guard !isAccessibilitySize else { return false }
        guard (idiom ?? currentIdiom()) == .pad else { return false }
        return horizontalSizeClass == .regular
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
