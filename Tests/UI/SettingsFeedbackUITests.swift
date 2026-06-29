import XCTest

final class SettingsFeedbackUITests: ModelsFlowUITestCase {
    func testFeedbackFormRequiresSummaryBeforeSending() throws {
        openSettingsTab()

        let feedbackLink = app.descendants(matching: .any).matching(identifier: "settings.feedbackForm").firstMatch
        if !feedbackLink.waitForExistence(timeout: 3) {
            app.swipeUp()
        }
        XCTAssertTrue(feedbackLink.waitForExistence(timeout: 8))
        feedbackLink.tap()

        let sendButton = app.buttons["feedback.send"]
        XCTAssertTrue(sendButton.waitForExistence(timeout: 8))
        XCTAssertFalse(sendButton.isEnabled)

        let itemField = app.textFields["feedback.specificItem"]
        XCTAssertTrue(itemField.waitForExistence(timeout: 8))
        itemField.tap()
        itemField.typeText("Paints")
        XCTAssertFalse(sendButton.isEnabled)

        let summaryField = app.textFields["feedback.summary"]
        XCTAssertTrue(summaryField.waitForExistence(timeout: 8))
        summaryField.tap()
        summaryField.typeText("Add more filter presets")

        waitForEnabled(sendButton, timeout: 8)
    }
}
