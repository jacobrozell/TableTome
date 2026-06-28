import SwiftUI
import TabletomeDomain

struct CombatPatrolStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        GameGuideStartHereShell(intro: intro) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TappableGuidePathStep(
                    number: 1,
                    title: String(localized: "Preview a Turn"),
                    detail: String(localized: "Never played before? Walk through each battle phase."),
                    destination: CombatPatrolSampleTurnLink(),
                    accessibilityId: "guide.combatPatrol.path.sampleTurn"
                )
                GuidePathInfoStep(
                    number: 2,
                    title: String(localized: "Guided Match"),
                    detail: String(
                        localized: """
                        Tap Start Guided Match below — then Use Starter Matchup for built-in armies.
                        """
                    ),
                    accessibilityId: "guide.combatPatrol.path.guidedMatch"
                )
            }
        } footer: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                GuidedMatchStartButton(
                    gameSystemId: .wh40k10eCp,
                    accessibilityId: "guide.combatPatrol.guidedMatch"
                )

                CombatPatrolWhatYouNeedCard()

                if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue) {
                    NavigationLink(value: GettingStartedLink(gameSystemId: GameSystemId.wh40k11e.rawValue)) {
                        Label(
                            String(localized: "Have Battleforce or Armageddon? (11th Edition)"),
                            systemImage: "scope"
                        )
                        .font(.caption.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentOnSurface)
                    .accessibilityIdentifier("guide.combatPatrol.wh40k11eCrossLink")
                }

                HStack(spacing: DesignTokens.Spacing.md) {
                    NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
                        Text(String(localized: "Getting Started"))
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    NavigationLink(value: CombatPatrolMissionsLink(gameSystemId: gameSystem.id)) {
                        Text(String(localized: "Missions Reference"))
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(Color.accentOnSurface)
            }
        }
        .accessibilityIdentifier("guide.combatPatrol.startHere")
    }

    private var intro: String {
        String(
            localized: """
            Box says Combat Patrol? This guide uses 10th Edition patrol rules — follow the steps, then play at the table.
            """
        )
    }
}
