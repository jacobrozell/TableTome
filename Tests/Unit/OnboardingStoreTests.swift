import XCTest
@testable import Tabletome

final class OnboardingStoreTests: XCTestCase {
    override func tearDown() {
        OnboardingStore.clearPersistedState()
        super.tearDown()
    }

    func testShouldPresentOnLaunchWhenNotCompleted() {
        OnboardingStore.clearPersistedState()

        XCTAssertFalse(UserDefaults.standard.bool(forKey: OnboardingStore.completedKey))
    }

    func testMarkCompletedClearsLaunchPresentation() {
        OnboardingStore.clearPersistedState()

        OnboardingStore.markCompleted()

        XCTAssertTrue(UserDefaults.standard.bool(forKey: OnboardingStore.completedKey))
    }

    func testClearPersistedStateRemovesCompletion() {
        OnboardingStore.markCompleted()

        OnboardingStore.clearPersistedState()

        XCTAssertFalse(UserDefaults.standard.bool(forKey: OnboardingStore.completedKey))
    }
}
