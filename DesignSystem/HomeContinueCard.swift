import SwiftUI
import TabletomeDomain

/// Shown on Play when the user should continue onboarding or resume an in-progress Guided Match.
struct HomeContinueCard: View {
    @Environment(AppRouter.self) private var router

    let continuation: PlayContinuation

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(continuation.title, systemImage: continuationIcon)
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(continuation.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            continuationButton
        }
        .accentHighlightCard()
        .accessibilityIdentifier("home.continueCard")
    }

    private var continuationButton: some View {
        Button(action: openContinuation) {
            continuationButtonLabel
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel(continuation.buttonTitle)
        .accessibilityHint(continuationAccessibilityHint)
        .accessibilityIdentifier(continuationAccessibilityIdentifier)
    }

    private var continuationAccessibilityHint: String {
        switch continuation.destination {
        case .gameGuide:
            String(localized: "Opens the game guide on the Play tab.")
        case .guidedMatch:
            if continuation.opensBattleTab {
                String(localized: "Opens Guided Match on the battle tracker where you left off.")
            } else {
                String(localized: "Opens Guided Match to continue setup or choose armies.")
            }
        }
    }

    private func openContinuation() {
        switch continuation.destination {
        case .gameGuide:
            router.openGameGuide(gameSystemId: continuation.gameSystemId)
        case .guidedMatch:
            router.openGuidedMatch(
                gameSystemId: continuation.gameSystemId,
                opensBattleTab: continuation.opensBattleTab
            )
        }
    }

    private var continuationButtonLabel: some View {
        Label(continuation.buttonTitle, systemImage: "play.circle.fill")
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
    }

    private var continuationAccessibilityIdentifier: String {
        switch continuation.destination {
        case .gameGuide:
            "home.continueGuide"
        case .guidedMatch:
            "home.continueGuidedMatch"
        }
    }

    private var continuationIcon: String {
        switch continuation.destination {
        case .gameGuide:
            "arrow.right.circle.fill"
        case .guidedMatch:
            "flag.checkered"
        }
    }
}
