import SwiftUI
import TabletomeDomain

struct CombatResolverAttackProfileBarSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let onSyncMultiAttack: () -> Void

    var body: some View {
        if let weapon = viewModel.selectedAttackerWeapon,
           let defender = viewModel.selectedDefenderUnit,
           let save = defender.save {
            let profile = WarscrollStatSummary.weaponCombatProfile(
                weapon,
                gameSystemId: viewModel.gameSystemId
            )
            Group {
                if isEmbedded {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(weapon.name)
                            .font(.caption.weight(.semibold))
                        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                            Text("\(profile) · Dmg \(viewModel.damage)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            Text(String(localized: "Save \(save)+"))
                                .font(.caption.weight(.semibold))
                        }
                    }
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "target")
                            .foregroundStyle(.secondary)
                        Text("\(weapon.name): \(profile) · Dmg \(viewModel.damage)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Text(String(localized: "Save \(save)+"))
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            .padding(DesignTokens.Spacing.sm)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            .onAppear { onSyncMultiAttack() }
        }
    }
}
