import XCTest

final class CollectionFlowUITests: ModelsFlowUITestCase {
    func testStarterBoxArmyPrefillsUnits() throws {
        openModelsTab()

        tapNewArmy()

        let starterToggle = app.switches["addStarterBoxUnits"]
        XCTAssertTrue(starterToggle.waitForExistence(timeout: 8))

        confirmAddArmy()

        tapArmy(named: "My Stormcast Eternals")

        XCTAssertTrue(app.staticTexts["Liberators (5)"].waitForExistence(timeout: 8))
    }

    func testManualAddUnitAfterEmptyArmy() throws {
        openModelsTab()

        tapNewArmy()

        let starterToggle = app.switches["addStarterBoxUnits"]
        if starterToggle.waitForExistence(timeout: 3) {
            if starterToggle.value as? String == "1" {
                starterToggle.tap()
            }
        }

        confirmAddArmy()

        tapArmy(named: "My Stormcast Eternals")

        app.buttons["addUnit"].tap()

        let nameField = app.textFields["unitName"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText("Liberators (5)")

        let addUnit = app.buttons["addUnitConfirm"]
        XCTAssertTrue(addUnit.waitForExistence(timeout: 5))
        XCTAssertTrue(addUnit.isEnabled)
        addUnit.tap()

        XCTAssertTrue(app.staticTexts["Liberators (5)"].waitForExistence(timeout: 8))
    }

    func testLoadSampleDataPopulatesCollection() throws {
        app.terminate()
        launchModelsFlow(persistent: false)

        openModelsTab()

        let sampleButton = app.buttons["loadSampleData"]
        XCTAssertTrue(sampleButton.waitForExistence(timeout: 5))
        sampleButton.tap()

        XCTAssertTrue(app.staticTexts["Hallowed Knights"].waitForExistence(timeout: 10))
    }
}
