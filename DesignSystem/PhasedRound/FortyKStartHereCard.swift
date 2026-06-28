import SwiftUI
import TabletomeDomain

/// Recommended paths for new and returning 40k players on the game guide screen.
struct FortyKStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        GameGuideStartHereShell(gameSystemId: .wh40k11e, intro: intro) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
                    NavigationLink(value: GettingStartedLink(gameSystemId: GameSystemId.wh40k10eCp.rawValue)) {
                        Label(
                            String(localized: "Have a Combat Patrol box? (10th Edition rules)"),
                            systemImage: "shippingbox"
                        )
                        .font(.caption.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentOnSurface)
                    .accessibilityIdentifier("guide.wh40k.combatPatrolCrossLink")
                }

                newPlayerTrack
                returningPlayerTrack
            }
        } footer: {
            GuidedMatchStartButton(
                gameSystemId: .wh40k11e,
                accessibilityId: "guide.wh40k.guidedMatch"
            )
        }
    }

    private var intro: String {
        String(
            localized: """
            Pick a path below, then play at the table with physical dice.
            """
        )
    }

    private var newPlayerTrack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "New to Warhammer 40,000"))
                .font(.subheadline.weight(.semibold))
            TappableGuidePathStep(
                number: 1,
                title: String(localized: "Preview a 40k Turn"),
                detail: String(localized: "Six phases — Command through Fight."),
                destination: Wh40k11eSampleTurnLink(),
                accessibilityId: "guide.wh40k.path.new.sampleTurn"
            )
            TappableGuidePathStep(
                number: 2,
                title: String(localized: "Getting Started"),
                detail: String(localized: "What you need, army size, and how a turn works."),
                destination: GettingStartedLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.wh40k.path.new.gettingStarted"
            )
            TappableGuidePathStep(
                number: 3,
                title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystem.id),
                detail: String(localized: "Search turn phases, combat, and glossary terms."),
                destination: RulesReferenceBrowseLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.wh40k.path.new.rules"
            )
            GuidePathInfoStep(
                number: 4,
                title: String(localized: "Guided Match"),
                detail: String(
                    localized: "Tap Start Guided Match below for the Armageddon starter matchup."
                ),
                accessibilityId: "guide.wh40k.path.new.guidedMatch"
            )
        }
    }

    private var returningPlayerTrack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Played 10th Edition?"))
                .font(.subheadline.weight(.semibold))
            TappableGuidePathStep(
                number: 1,
                title: String(localized: "What's New in 11e"),
                detail: String(localized: "Detachments, terrain objectives, combat, and battle-shock."),
                destination: EditionMigrationLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.wh40k.path.return.whatsNew"
            )
            TappableGuidePathStep(
                number: 2,
                title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystem.id),
                detail: String(localized: "Jump to changed topics from the guide."),
                destination: RulesReferenceBrowseLink(gameSystemId: gameSystem.id),
                accessibilityId: "guide.wh40k.path.return.rules"
            )
            GuidePathInfoStep(
                number: 3,
                title: String(localized: "Guided Match"),
                detail: String(
                    localized: "Tap Start Guided Match below — Operation Imperator vs Waaagh! Armageddon."
                ),
                accessibilityId: "guide.wh40k.path.return.guidedMatch"
            )
        }
    }
}
