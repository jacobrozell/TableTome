import SwiftUI
import TabletomeDomain

struct LoadoutSummaryCard: View {
    let playerName: String
    let armyName: String
    let regimentAbility: ArmyRuleOption?
    let enhancement: ArmyRuleOption?
    var secondaryObjective: ArmyRuleOption? = nil
    var battleTacticDeckName: String? = nil
    var isAttacker: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text(playerName)
                    .font(.headline)
                if isAttacker {
                    Text(String(localized: "Attacker"))
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                }
            }
            Text(armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if regimentAbility != nil || enhancement != nil || secondaryObjective != nil || battleTacticDeckName != nil {
                Divider()
                if let regimentAbility {
                    loadoutRow(
                        title: String(localized: "Regiment Ability"),
                        option: regimentAbility
                    )
                }
                if let enhancement {
                    loadoutRow(
                        title: String(localized: "Enhancement"),
                        option: enhancement
                    )
                }
                if let secondaryObjective {
                    loadoutRow(
                        title: String(localized: "Secondary Objective"),
                        option: secondaryObjective
                    )
                }
                if let battleTacticDeckName {
                    battleTacticDeckRow(deckName: battleTacticDeckName)
                }
            } else {
                Text(String(localized: "Complete loadout choices in match setup."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .surfaceCard()
    }

    private func loadoutRow(title: String, option: ArmyRuleOption) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(option.name)
                .font(.subheadline.bold())
            Text(option.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func battleTacticDeckRow(deckName: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Battle Tactic Deck"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(deckName)
                .font(.subheadline.bold())
            Text(
                String(
                    localized: "Shuffle this 12-card deck from your starter box before the battle. Round 1: draw 3 from the top."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
