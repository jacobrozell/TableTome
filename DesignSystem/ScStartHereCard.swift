import SwiftUI
import TabletomeDomain

/// Recommended paths for StarCraft TMG on the game guide screen.
struct ScStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Start here"), systemImage: "flag.checkered")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Pick a path below, then run a guided match at the table. Roll physical dice — \
                    the app tracks supply and scoring.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                newToWargamesTrack
                starCraftPlayerTrack
            }

            ScWhatYouNeedCard()

            NavigationLink(value: GuidedMatchLink(gameSystemId: .scTmg)) {
                Label(String(localized: "Start Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.scTmg.guidedMatch")
        }
        .accentHighlightCard()
    }

    private var newToWargamesTrack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "New to wargames"))
                .font(.subheadline.weight(.semibold))
            TappableGuidePathStep(
                number: 1,
                title: String(localized: "Getting Started"),
                detail: String(localized: "Minerals, vespene, four phases, and reserves."),
                destination: GettingStartedLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.scTmg.path.new.gettingStarted"
            )
            GuidePathInfoStep(
                number: 2,
                title: String(localized: "Guided Match"),
                detail: String(
                    localized: "Tap Start Guided Match below for the Raynor vs Kerrigan Founders Edition matchup."
                ),
                accessibilityId: "guide.scTmg.path.new.guidedMatch"
            )
        }
    }

    private var starCraftPlayerTrack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Played StarCraft II?"))
                .font(.subheadline.weight(.semibold))
            TappableGuidePathStep(
                number: 1,
                title: String(localized: "RTS → Tabletop"),
                detail: String(localized: "APM, supply cap, fog of war, and economy."),
                destination: EditionMigrationLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.scTmg.path.rts.bridge"
            )
            GuidePathInfoStep(
                number: 2,
                title: String(localized: "Guided Match"),
                detail: String(
                    localized: "Tap Start Guided Match below for step-by-step setup and battle tracking."
                ),
                accessibilityId: "guide.scTmg.path.rts.guidedMatch"
            )
            TappableGuidePathStep(
                number: 3,
                title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystem.id),
                detail: String(localized: "Surge, activations, and objective Supply."),
                destination: RulesReferenceBrowseLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.scTmg.path.rts.rules"
            )
        }
    }
}
