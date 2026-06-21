import SwiftUI
import TabletomeDomain

/// Recommended paths for new and returning 40k players on the game guide screen.
struct FortyKStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Start here"), systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                if ReleaseSurface.showsNewEditionBadge(for: gameSystem.id) {
                    NewEditionBadge()
                }
            }

            Text(
                String(
                    localized: """
                    New to the hobby or upgrading from 10th Edition? Pick a path — about 10 minutes of reading, \
                    then play at the table with physical dice.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
                NavigationLink(value: GettingStartedLink(gameSystemId: GameSystemId.wh40k10eCp.rawValue)) {
                    Label(
                        String(localized: "Have a Combat Patrol box instead?"),
                        systemImage: "shippingbox"
                    )
                    .font(.caption.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .accessibilityIdentifier("guide.wh40k.combatPatrolCrossLink")
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                newPlayerTrack
                returningPlayerTrack
            }

            NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.wh40k.gettingStarted")

            if !gameSystem.editionMigrationSteps.isEmpty {
                NavigationLink(value: EditionMigrationLink(gameSystemId: gameSystem.id)) {
                    Label(String(localized: "What's New in 11th Edition"), systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("guide.wh40k.whatsNew")
            }

            NavigationLink(value: GuidedMatchLink(gameSystemId: .wh40k11e)) {
                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.wh40k.guidedMatch")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
    }

    private var newPlayerTrack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "New to Warhammer 40,000"))
                .font(.subheadline.weight(.semibold))
            TappableGuidePathStep(
                number: 1,
                title: String(localized: "Preview a 40k Turn"),
                detail: String(localized: "Six phases — Command through Fight, with 11e charge and pile-in rules."),
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
            TappableGuidePathStep(
                number: 4,
                title: String(localized: "Guided Match"),
                detail: String(localized: "Armageddon starter matchup with datasheets and battle tracker."),
                destination: GuidedMatchLink(gameSystemId: .wh40k11e),
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
            TappableGuidePathStep(
                number: 3,
                title: String(localized: "Guided Match"),
                detail: String(localized: "Operation Imperator vs Waaagh! Armageddon — tap Use Starter Matchup."),
                destination: GuidedMatchLink(gameSystemId: .wh40k11e),
                accessibilityId: "guide.wh40k.path.return.guidedMatch"
            )
        }
    }
}
