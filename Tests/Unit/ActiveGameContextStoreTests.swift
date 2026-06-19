import XCTest
@testable import Tabletome

final class ActiveGameContextStoreTests: XCTestCase {
    override func tearDown() {
        ActiveGameContextStore.clearPersistedState()
        super.tearDown()
    }

    func testPersistsSelectedGameSystem() {
        ActiveGameContextStore.setActiveGameSystem("wh40k-10e-cp")
        XCTAssertEqual(ActiveGameContextStore.gameSystemId, "wh40k-10e-cp")
    }
}
