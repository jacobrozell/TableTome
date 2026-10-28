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
    var isPlayerOne: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                TTPlayerToken(isPlayerOne: isPlayerOne, size: 28)
                Text(playerName)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                if isAttacker {
                    TTBadge(String(localized: "Attacker"), tone: .brand)
                }
            }
            Text(armyName)
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkSecondary)

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
        TTKeyValueRow(title, value: option.name)
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
