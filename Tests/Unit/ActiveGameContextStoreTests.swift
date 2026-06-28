import XCTest
@testable import Tabletome

final class ActiveGameContextPersistenceTests: XCTestCase {
    override func tearDown() {
        ActiveGameContextPersistence.resetForTests()
        super.tearDown()
    }

    func testPersistsActiveGameSystemId() {
        ActiveGameContextPersistence.gameSystemId = "wh40k-10e-cp"
        XCTAssertEqual(ActiveGameContextPersistence.gameSystemId, "wh40k-10e-cp")
    }
}
