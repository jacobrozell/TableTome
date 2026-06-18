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
                    with supply-aware battle tracking.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                trackSection(
                    title: String(localized: "New to wargames"),
                    steps: [
                        (String(localized: "Getting Started"), String(localized: "Minerals, vespene, four phases, and reserves.")),
                        (String(localized: "Guided Match"), String(localized: "2-Player Founders Edition — Raynor vs Kerrigan.")),
                        (String(localized: "Battle tracker"), String(localized: "Activations, Pass, and supply coaching at the table."))
                    ]
                )

                trackSection(
                    title: String(localized: "Played StarCraft II?"),
                    steps: [
                        (String(localized: "RTS → Tabletop"), String(localized: "APM, supply cap, fog of war, and economy.")),
                        (String(localized: "Guided Match"), String(localized: "Step-by-step setup and battle tracking for SC TMG.")),
                        (GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: "sc-tmg"), String(localized: "Surge, activations, and objective Supply."))
                    ]
                )
            }

            NavigationLink {
                GettingStartedView(gameSystem: gameSystem)
            } label: {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.scTmg.gettingStarted")

            if !gameSystem.editionMigrationSteps.isEmpty {
                NavigationLink {
                    EditionMigrationView(gameSystem: gameSystem)
                } label: {
                    Label(String(localized: "RTS → Tabletop"), systemImage: "gamecontroller")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("guide.scTmg.rtsBridge")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
    }

    private func trackSection(title: String, steps: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .frame(minWidth: 20, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.0)
                            .font(.subheadline.weight(.medium))
                        Text(step.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
