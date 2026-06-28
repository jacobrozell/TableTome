import SwiftUI
import TabletomeDomain

/// Recommended paths for new and returning 40k players on the game guide screen.
struct FortyKStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Start here"), systemImage: "flag.checkered")
                    .font(.headline)
                    .foregroundStyle(Color.accentOnSurface)
                if ReleaseSurface.showsNewEditionBadge(for: gameSystem.id) {
                    NewEditionBadge()
                }
            }

            Text(
                String(
                    localized: """
                    Pick a path below, then play at the table with physical dice.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

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

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                newPlayerTrack
                returningPlayerTrack
            }

            NavigationLink(value: GuidedMatchLink(gameSystemId: .wh40k11e)) {
                Label(String(localized: "Start Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.wh40k.guidedMatch")
        }
        .accentHighlightCard()
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
