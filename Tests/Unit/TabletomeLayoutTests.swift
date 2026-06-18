import XCTest
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
    }
}
