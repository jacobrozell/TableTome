import XCTest
@testable import Tabletome

final class AppSupportTests: XCTestCase {
    func testFeedbackEmailIsConfigured() {
        XCTAssertTrue(AppSupport.feedbackEmail.contains("@"))
    }

    func testMailSubjectIncludesCategoryTag() {
        let draft = FeedbackDraft(
            category: .paintColour,
            specificItem: "Macragge Blue",
            summary: "Fix swatch",
            details: "Should be darker"
        )
        let subject = AppSupport.mailSubject(for: draft)
        XCTAssertTrue(subject.contains("[Tabletome]"))
        XCTAssertTrue(subject.contains("Paint"))
        XCTAssertTrue(subject.contains("Macragge Blue"))
    }

    func testMailBodyIncludesSummaryAndDiagnostics() {
        let draft = FeedbackDraft(
            category: .basingMaterial,
            specificItem: "Winter Tuft",
            summary: "Add to catalog",
            details: "Army Painter product"
        )
        let body = AppSupport.mailBody(for: draft)
        XCTAssertTrue(body.contains("Summary: Add to catalog"))
        XCTAssertTrue(body.contains("Basing material"))
        XCTAssertTrue(body.contains("App: Tabletome"))
    }

    func testMailtoURLUsesConfiguredRecipient() throws {
        let draft = FeedbackDraft(
            category: .bug,
            specificItem: "Battle tracker",
            summary: "Score reset",
            details: ""
        )
        let url = AppSupport.mailtoURL(for: draft)
        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertTrue(url.absoluteString.contains(AppSupport.feedbackEmail))
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let subject = components?.queryItems?.first { $0.name == "subject" }?.value
        XCTAssertNotNil(subject)
        XCTAssertTrue(subject?.contains("Bug") == true)
    }

    func testInvalidDraftWhenSummaryEmpty() {
        let draft = FeedbackDraft(category: .other, specificItem: "", summary: "   ", details: "")
        XCTAssertFalse(draft.isValid)
    }
}
