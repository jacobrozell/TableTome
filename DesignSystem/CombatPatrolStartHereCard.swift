import SwiftUI
import TabletomeDomain

struct CombatPatrolStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Start here"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    New to Warhammer 40,000 or small-box games? Follow this path for your first Combat Patrol \
                    battle — guided setup, dice help, and scoring in the app.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            CombatPatrolWhatYouNeedCard()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TappableGuidePathStep(
                    number: 1,
                    title: String(localized: "Preview a Turn"),
                    detail: String(localized: "Optional — walk through each battle phase in order."),
                    destination: CombatPatrolSampleTurnLink(),
                    accessibilityId: "guide.combatPatrol.path.sampleTurn"
                )
                TappableGuidePathStep(
                    number: 2,
                    title: String(localized: "Guided Match"),
                    detail: String(
                        localized: """
                        Tap Use Starter Matchup for built-in armies. Mission maps and Getting Started open from setup.
                        """
                    ),
                    destination: GuidedMatchLink(gameSystemId: .wh40k10eCp),
                    accessibilityId: "guide.combatPatrol.path.guidedMatch"
                )
            }

            HStack(spacing: DesignTokens.Spacing.md) {
                NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
                    Text(String(localized: "Getting Started"))
                        .font(.caption.weight(.semibold))
                }
                NavigationLink(value: CombatPatrolMissionsLink(gameSystemId: gameSystem.id)) {
                    Text(String(localized: "Missions Reference"))
                        .font(.caption.weight(.semibold))
                }
            }
            .foregroundStyle(Color.accentOnSurface)
        }
        .accentHighlightCard()
        .accessibilityIdentifier("guide.combatPatrol.startHere")
    }
}
