import SwiftUI
import TabletomeDomain

/// Shown on Play when the user should continue onboarding or resume an in-progress Guided Match.
struct HomeContinueCard: View {
    let continuation: PlayContinuation

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(continuation.title, systemImage: continuationIcon)
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(continuation.message)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            continuationLink
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityIdentifier("home.continueCard")
    }

    @ViewBuilder
    private var continuationLink: some View {
        switch continuation.destination {
        case .gameGuide:
            NavigationLink(value: continuation.gameSystemId) {
                continuationButtonLabel
            }
            .buttonStyle(.borderedProminent)
            .simultaneousGesture(TapGesture().onEnded {
                ActiveGameContextStore.setActiveGameSystem(continuation.gameSystemId)
            })
            .accessibilityIdentifier("home.continueGuide")
        case .guidedMatch:
            NavigationLink(
                value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: continuation.gameSystemId))
            ) {
                continuationButtonLabel
            }
            .buttonStyle(.borderedProminent)
            .simultaneousGesture(TapGesture().onEnded {
                ActiveGameContextStore.setActiveGameSystem(continuation.gameSystemId)
            })
            .accessibilityIdentifier("home.continueGuidedMatch")
        }
    }

    private var continuationButtonLabel: some View {
        Label(continuation.buttonTitle, systemImage: "play.circle.fill")
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
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
