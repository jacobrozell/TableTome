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

    func testAddPaintFromEmptyPaintsTab() throws {
        app.terminate()
        launchModelsFlow(persistent: false)

        openPaintsTab()

        let emptyAdd = app.buttons["paint.add.empty"]
        XCTAssertTrue(emptyAdd.waitForExistence(timeout: 8))
        emptyAdd.tap()

        let saveButton = app.buttons["paint.save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 8))
        XCTAssertFalse(saveButton.isEnabled)

        let nameField = app.textFields["paint.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText("Kantor Blue")

        waitForEnabled(saveButton, timeout: 8)
        saveButton.tap()

        let paintRow = app.descendants(matching: .any).matching(identifier: "paint.row.Kantor Blue").firstMatch
        XCTAssertTrue(paintRow.waitForExistence(timeout: 8))
        paintRow.tap()

        XCTAssertTrue(app.staticTexts["Kantor Blue"].waitForExistence(timeout: 8))
    }
}
