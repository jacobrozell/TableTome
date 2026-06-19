import SwiftUI
import TabletomeDomain

struct CombatPatrolStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Start here"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

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
                    title: String(localized: "Getting Started"),
                    detail: String(localized: "What you need, board size, and how a turn works."),
                    destination: GettingStartedLink(gameSystemId: gameSystem.id),
                    accessibilityId: "guide.combatPatrol.path.gettingStarted"
                )
                TappableGuidePathStep(
                    number: 2,
                    title: String(localized: "Preview a Turn"),
                    detail: String(localized: "Optional — walk through each battle phase in order."),
                    destination: CombatPatrolSampleTurnLink(),
                    accessibilityId: "guide.combatPatrol.path.sampleTurn"
                )
                TappableGuidePathStep(
                    number: 3,
                    title: String(localized: "Guided Match"),
                    detail: String(localized: "Tap Use Starter Matchup for built-in armies, or pick your patrol boxes."),
                    destination: GuidedMatchLink(gameSystemId: .wh40k10eCp),
                    accessibilityId: "guide.combatPatrol.path.guidedMatch"
                )
            }

            NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.combatPatrol.gettingStarted")

            NavigationLink(value: CombatPatrolSampleTurnLink()) {
                Label(String(localized: "Preview a Turn"), systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.combatPatrol.sampleTurn")

            NavigationLink(value: GuidedMatchLink(gameSystemId: .wh40k10eCp)) {
                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.combatPatrol.guidedMatch")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .accessibilityIdentifier("guide.combatPatrol.startHere")
    }
}
