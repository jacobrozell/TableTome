import SwiftUI
import TabletomeDomain

/// Recommended paths for StarCraft TMG on the game guide screen.
struct ScStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Start here"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(
                String(
                    localized: """
                    New to tabletop wargames or coming from StarCraft II? Pick a path — then run a full guided match \
                    with supply-aware battle tracking. Roll physical dice at the table.
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

            NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.scTmg.gettingStarted")

            if !gameSystem.editionMigrationSteps.isEmpty {
                NavigationLink(value: EditionMigrationLink(gameSystemId: gameSystem.id)) {
                    Label(String(localized: "RTS → Tabletop"), systemImage: "gamecontroller")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("guide.scTmg.rtsBridge")
            }

            NavigationLink(value: GuidedMatchLink(gameSystemId: .scTmg)) {
                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.scTmg.guidedMatch")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
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
            TappableGuidePathStep(
                number: 2,
                title: String(localized: "Guided Match"),
                detail: String(localized: "Founders Edition — Raynor vs Kerrigan starter matchup."),
                destination: GuidedMatchLink(gameSystemId: .scTmg),
                accessibilityId: "guide.scTmg.path.new.guidedMatch"
            )
            TappableGuidePathStep(
                number: 3,
                title: String(localized: "Battle tracker"),
                detail: String(localized: "Activations, Pass, and supply coaching at the table."),
                destination: GuidedMatchLink(gameSystemId: .scTmg),
                accessibilityId: "guide.scTmg.path.new.battleTracker"
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
            TappableGuidePathStep(
                number: 2,
                title: String(localized: "Guided Match"),
                detail: String(localized: "Step-by-step setup and battle tracking for SC TMG."),
                destination: GuidedMatchLink(gameSystemId: .scTmg),
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
