import SwiftUI
import TabletomeDomain

struct LoadoutSummaryCard: View {
    let playerName: String
    let armyName: String
    let regimentAbility: ArmyRuleOption?
    let enhancement: ArmyRuleOption?
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

            if regimentAbility != nil || enhancement != nil {
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
            } else {
                Text(String(localized: "Pick regiment ability and enhancement in match setup."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
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
}
