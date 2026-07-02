import SwiftUI
import XCTest
#if canImport(UIKit)
import UIKit
#endif
@testable import Tabletome

final class TabletomeLayoutTests: XCTestCase {
    @MainActor
    func testPadLandscapeRequiresPadIdiomAndCompactHeight() {
        XCTAssertTrue(
            TabletomeLayout.isPadLandscape(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            )
        )
        XCTAssertFalse(
            TabletomeLayout.isPadLandscape(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
        XCTAssertTrue(
            TabletomeLayout.isPadLandscape(
                idiom: .pad,
                horizontalSizeClass: .compact,
                verticalSizeClass: .compact
            )
        )
    }

    @MainActor
    func testPhoneLandscapeIsNotPadLandscapeEvenWithRegularWidth() {
        let context = TabletomeLayout.context(
            idiom: .phone,
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        )
        XCTAssertEqual(context, .phoneLandscape)
        XCTAssertFalse(
            TabletomeLayout.isPadLandscape(
                idiom: .phone,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            )
        )
    }

    @MainActor
    func testPhonePortraitContext() {
        XCTAssertEqual(
            TabletomeLayout.context(
                idiom: .phone,
                horizontalSizeClass: .compact,
                verticalSizeClass: .regular
            ),
            .phonePortrait
        )
    }

    @MainActor
    func testPhoneLandscapePrefersCollapsedBattleChrome() {
        XCTAssertTrue(TabletomeLayoutContext.phoneLandscape.prefersCollapsedBattleChrome)
        XCTAssertFalse(TabletomeLayoutContext.phonePortrait.prefersCollapsedBattleChrome)
        XCTAssertFalse(TabletomeLayoutContext.padLandscape.prefersCollapsedBattleChrome)
    }

    @MainActor
    func testCompactPhoneHeightUsesThreshold() {
        XCTAssertTrue(TabletomeLayout.isCompactPhoneHeight(idiom: .phone, boundsHeight: 667))
        XCTAssertTrue(TabletomeLayout.isCompactPhoneHeight(idiom: .phone, boundsHeight: 812))
        XCTAssertFalse(TabletomeLayout.isCompactPhoneHeight(idiom: .phone, boundsHeight: 852))
        XCTAssertFalse(TabletomeLayout.isCompactPhoneHeight(idiom: .pad, boundsHeight: 667))
    }

    @MainActor
    func testPrefersCompactGuidedMatchChrome() {
        XCTAssertTrue(TabletomeLayout.prefersCompactGuidedMatchChrome(.phoneLandscape))
        XCTAssertFalse(TabletomeLayout.prefersCompactGuidedMatchChrome(.padPortrait))
        XCTAssertTrue(
            TabletomeLayout.prefersCompactGuidedMatchChrome(.phonePortrait, idiom: .phone, boundsHeight: 667)
        )
        XCTAssertFalse(
            TabletomeLayout.prefersCompactGuidedMatchChrome(.phonePortrait, idiom: .phone, boundsHeight: 852)
        )
    }

    @MainActor
    func testUsesLargeScreenLayoutIncludesMacStyleIdiom() {
        XCTAssertTrue(
            TabletomeLayout.usesLargeScreenLayout(idiom: .other, horizontalSizeClass: .regular)
        )
        XCTAssertFalse(
            TabletomeLayout.usesLargeScreenLayout(idiom: .other, horizontalSizeClass: .compact)
        )
        XCTAssertTrue(
            TabletomeLayout.usesSideBySideLayout(
                idiom: .other,
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
    }

    @MainActor
    func testUsesSideBySideLayoutRequiresPadIdiom() {
        XCTAssertFalse(
            TabletomeLayout.usesSideBySideLayout(
                idiom: .phone,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            )
        )
        XCTAssertTrue(
            TabletomeLayout.usesSideBySideLayout(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
        XCTAssertFalse(
            TabletomeLayout.usesSideBySideLayout(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular,
                isAccessibilitySize: true
            )
        )
        XCTAssertFalse(
            TabletomeLayout.usesSideBySideLayout(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular,
                isAccessibilitySize: DynamicTypeSize.xxxLarge.needsLayoutAdaptation
            )
        )
    }

    func testNeedsLayoutAdaptation() {
        XCTAssertFalse(DynamicTypeSize.large.needsLayoutAdaptation)
        XCTAssertFalse(DynamicTypeSize.xxLarge.needsLayoutAdaptation)
        XCTAssertTrue(DynamicTypeSize.xxxLarge.needsLayoutAdaptation)
        XCTAssertTrue(DynamicTypeSize.accessibility1.needsLayoutAdaptation)
        XCTAssertTrue(DynamicTypeSize.accessibility5.needsLayoutAdaptation)
    }

    @MainActor
    func testPhoneLandscapeRegularWidthDoesNotUsePadSplitNavigation() {
        XCTAssertEqual(
            TabletomeLayout.context(
                idiom: .phone,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            ),
            .phoneLandscape
        )
        XCTAssertFalse(
            TabletomeLayout.context(
                idiom: .phone,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            ).usesPadSplitNavigation
        )
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            XCTAssertFalse(AdaptiveLayout.usesSplitNavigation(.regular))
            XCTAssertFalse(AdaptiveLayout.usesSidebarListStyle(.regular))
        }
        #endif
    }

    @MainActor
    func testPadLandscapeUsesPadSplitNavigationWhenWidthIsRegular() {
        XCTAssertEqual(
            TabletomeLayout.context(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            ),
            .padLandscape
        )
        XCTAssertTrue(
            TabletomeLayout.context(
                idiom: .pad,
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            ).usesPadSplitNavigation
        )
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            XCTAssertTrue(AdaptiveLayout.usesSplitNavigation(.regular))
            XCTAssertTrue(AdaptiveLayout.usesSidebarListStyle(.regular))
        }
        #endif
    }

    @MainActor
    func testAdaptiveLayoutSplitRequiresPadIdiomOnPhoneSimulator() {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            XCTAssertFalse(AdaptiveLayout.usesSplitNavigation(.regular))
            XCTAssertFalse(AdaptiveLayout.usesSidebarListStyle(.regular))
        }
        #endif
    }

    @MainActor
    func testSplitSidebarUsesSelectionStyleWhenPreferredEvenIfCompactWidth() {
        XCTAssertFalse(AdaptiveLayout.usesSidebarListStyle(.compact))
        XCTAssertTrue(AdaptiveLayout.usesSidebarListStyle(.compact, preferSelection: true))
    }
}
