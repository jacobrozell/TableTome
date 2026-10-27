import XCTest

/// Guided Match navigation and layout smoke tests in iPhone landscape.
@MainActor
final class GuidedMatchLandscapeUITests: XCTestCase {
    private var app: XCUIApplication!

    private let guidedMatchLaunchArgs = [
        "-skip_onboarding",
        "-reset_user_defaults",
        "-onboarding_choice",
        "aos-spearhead",
        "-open_guided_match",
        "-apply_starter_matchup"
    ]

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func launchApp(extraArguments: [String] = []) {
        app.terminate()
        app.launchArguments = guidedMatchLaunchArgs + extraArguments
        app.launch()
    }

    func testGuidedMatchSurvivesLandscapeRotation() {
        launchApp()
        let guidedMatch = app.descendants(matching: .any)["guidedMatch.screen"]
        XCTAssertTrue(guidedMatch.waitForExistence(timeout: 12))

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(guidedMatch.waitForExistence(timeout: 4), "Guided Match should stay open in landscape")

        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(guidedMatch.waitForExistence(timeout: 4), "Guided Match should stay open after rotating back")
    }

    func testBattleTrackerUsesPhoneLandscapeLayout() {
        launchApp(extraArguments: ["-open_battle_tracker"])

        let guidedMatch = app.descendants(matching: .any)["guidedMatch.screen"]
        XCTAssertTrue(guidedMatch.waitForExistence(timeout: 20))

        let battleMarker = app.descendants(matching: .any)["spearheadBattle.vpSummary"]
        if !battleMarker.waitForExistence(timeout: 25) {
            let battleTab = app.buttons["guidedMatch.hubTab.battle"]
            if battleTab.waitForExistence(timeout: 4) {
                battleTab.tap()
            }
        }
        XCTAssertTrue(
            battleMarker.waitForExistence(timeout: 15),
            "Spearhead battle tracker should appear after launch automation completes setup"
        )

        XCUIDevice.shared.orientation = .landscapeLeft

        let opponentColumn = app.descendants(matching: .any)["spearheadBattle.phoneLandscape.opponentColumn"]
        XCTAssertTrue(
            opponentColumn.waitForExistence(timeout: 8),
            "Spearhead battle should use the phone landscape split layout"
        )
        XCTAssertTrue(battleMarker.waitForExistence(timeout: 4))
    }

    func testStartGuidedMatchFromChooserInLandscape() {
        app.terminate()
        app.launchArguments = [
            "-skip_onboarding",
            "-reset_user_defaults",
            "-onboarding_choice",
            "aos-spearhead"
        ]
        app.launch()

        XCUIDevice.shared.orientation = .landscapeLeft

        let startButton = app.buttons["home.chooser.spearhead.startGuidedMatch"]
        if !startButton.waitForExistence(timeout: 6) {
            let continueCard = app.buttons["home.continueCard"]
            XCTAssertTrue(continueCard.waitForExistence(timeout: 6))
            continueCard.tap()
        } else {
            startButton.tap()
        }

        let guidedMatch = app.descendants(matching: .any)["guidedMatch.screen"]
        XCTAssertTrue(guidedMatch.waitForExistence(timeout: 10))
    }
}
