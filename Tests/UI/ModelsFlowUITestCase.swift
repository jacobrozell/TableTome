import XCTest

/// Shared launch configuration for Models / Collection UI tests.
class ModelsFlowUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        launchModelsFlow(persistent: true)
    }

    func launchModelsFlow(persistent: Bool) {
        app = XCUIApplication()
        var args = [
            "-skip_onboarding",
            "-reset_user_defaults",
            "-ui_testing_models_flow",
            "-onboarding_choice",
            "aos-spearhead",
            "UI-Testing-LightTheme"
        ]
        args.append(persistent ? "UI-Testing-Persistent" : "UI-Testing")
        app.launchArguments = args
        app.launch()
    }

    func openModelsTab() {
        let modelsTab = app.buttons["tab.bench"]
        XCTAssertTrue(modelsTab.waitForExistence(timeout: 8))
        modelsTab.tap()
    }

    func tapNewArmy() {
        let toolbarButton = app.buttons["newArmy"]
        if toolbarButton.waitForExistence(timeout: 3) {
            toolbarButton.tap()
            return
        }
        app.buttons["newArmyEmpty"].tap()
    }

    func confirmAddArmy() {
        let addButton = app.buttons["addArmyConfirm"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 8))
        waitForEnabled(addButton, timeout: 8)
        addButton.tap()

        let newArmy = app.buttons["newArmy"]
        XCTAssertTrue(newArmy.waitForExistence(timeout: 8))
    }

    func tapArmy(named name: String) {
        let identifier = app.descendants(matching: .any).matching(identifier: "army-\(name)").firstMatch
        if identifier.waitForExistence(timeout: 8) {
            identifier.tap()
            return
        }
        let label = app.staticTexts[name]
        XCTAssertTrue(label.waitForExistence(timeout: 8))
        label.tap()
    }

    func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval) {
        let enabled = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: enabled, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Expected \(element) to become enabled")
    }
}
