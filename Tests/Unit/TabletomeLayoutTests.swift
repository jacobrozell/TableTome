import XCTest
@testable import Tabletome

final class TabletomeLayoutTests: XCTestCase {
    func testPadLandscapeRequiresRegularWidthAndCompactHeight() {
        XCTAssertTrue(
            TabletomeLayout.isPadLandscape(
                horizontalSizeClass: .regular,
                verticalSizeClass: .compact
            )
        )
        XCTAssertFalse(
            TabletomeLayout.isPadLandscape(
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
        XCTAssertFalse(
            TabletomeLayout.isPadLandscape(
                horizontalSizeClass: .compact,
                verticalSizeClass: .compact
            )
        )
    }
}
