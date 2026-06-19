import SwiftUI
import TabletomeDomain

/// Shown on Play when the user picked a game during onboarding but has not opened its guide yet.
struct HomeContinueCard: View {
    let gameSystemId: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Continue your path"), systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(continuationMessage)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            NavigationLink(value: gameSystemId) {
                Label(openGuideLabel, systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .simultaneousGesture(TapGesture().onEnded {
                ActiveGameContextStore.setActiveGameSystem(gameSystemId)
            })
            .accessibilityIdentifier("home.continueGuide")
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

    private var continuationMessage: String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return String(
                localized: """
                You picked Age of Sigmar Spearhead. Open the guide for setup steps, then run Guided Match at the table.
                """
            )
        case GameSystemId.wh40k10eCp.rawValue:
            return String(
                localized: """
                You picked Combat Patrol. Open the guide for missions and setup, then start Guided Match when you're ready.
                """
            )
        case GameSystemId.wh40k11e.rawValue:
            return String(
                localized: """
                You picked full Warhammer 40,000. Open the guide for deployment and phase tips, then run Guided Match.
                """
            )
        case GameSystemId.scTmg.rawValue:
            return String(
                localized: """
                You picked StarCraft: The Miniatures Game. Open the guide for economy and phases, then run Guided Match.
                """
            )
        default:
            return String(
                localized: """
                Open your game guide for setup steps, then run Guided Match at the table.
                """
            )
        }
    }

    private var openGuideLabel: String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return String(localized: "Open Spearhead guide")
        case GameSystemId.wh40k10eCp.rawValue:
            return String(localized: "Open Combat Patrol guide")
        case GameSystemId.wh40k11e.rawValue:
            return String(localized: "Open Warhammer 40,000 guide")
        case GameSystemId.scTmg.rawValue:
            return String(localized: "Open StarCraft guide")
        default:
            return String(localized: "Open game guide")
        }
    }
}
