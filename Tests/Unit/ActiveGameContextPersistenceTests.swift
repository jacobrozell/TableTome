import XCTest
@testable import Tabletome
@testable import TabletomeDomain

final class ActiveGameContextPersistenceTests: XCTestCase {
    override func tearDown() {
        ActiveGameContextPersistence.resetForTests()
        super.tearDown()
    }

    func testPersistsActiveGameSystemId() {
        ActiveGameContextPersistence.gameSystemId = GameSystemId.aosSpearhead.rawValue
        XCTAssertEqual(
            ActiveGameContextPersistence.gameSystemId,
            GameSystemId.aosSpearhead.rawValue
        )
    }
}
