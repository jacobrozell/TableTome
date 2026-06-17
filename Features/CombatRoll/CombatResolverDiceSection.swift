import SwiftUI
import TabletomeDomain

struct CombatResolverDiceSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let isSimulated: Bool
    let accessibilityPrefix: String

    var body: some View {
        VStack(alignment: .leading, spacing: isEmbedded ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md) {
            if isEmbedded {
                Text(String(localized: "Your Dice"))
                    .font(.subheadline.weight(.semibold))
            } else {
                SectionHeader(title: String(localized: "Your Dice"), systemImage: "dice.fill")
            }

            if let weapon = viewModel.selectedAttackerWeapon {
                diceField(
                    label: String(localized: "Hit roll (\(weapon.hit)+)"),
                    value: $viewModel.hitRoll,
                    accessibilityId: "\(accessibilityPrefix).hitRoll",
                    rollAccessibilityId: "\(accessibilityPrefix).roll.hit",
                    onRoll: { viewModel.rollHit() }
                )
                diceField(
                    label: String(localized: "Wound roll (\(weapon.wound)+)"),
                    value: $viewModel.woundRoll,
                    accessibilityId: "\(accessibilityPrefix).woundRoll",
                    rollAccessibilityId: "\(accessibilityPrefix).roll.wound",
                    onRoll: { viewModel.rollWound() }
                )
            }
            if let save = viewModel.selectedDefenderUnit?.save {
                diceField(
                    label: String(localized: "Save roll (\(save)+)"),
                    value: $viewModel.saveRoll,
                    accessibilityId: "\(accessibilityPrefix).saveRoll",
                    rollAccessibilityId: "\(accessibilityPrefix).roll.save",
                    onRoll: { viewModel.rollSave() }
                )
            }
            if let ward = viewModel.activeWardTarget {
                diceField(
                    label: String(localized: "Ward roll (\(ward)+)"),
                    value: $viewModel.wardRoll,
                    accessibilityId: "\(accessibilityPrefix).wardRoll",
                    rollAccessibilityId: "\(accessibilityPrefix).roll.ward",
                    onRoll: { viewModel.rollWard() }
                )
            }

            if case .variable(let kind) = viewModel.selectedAttackerWeapon?.damageKind {
                Stepper(
                    String(localized: "Damage rolled (\(kind.rawValue)): \(viewModel.damage)"),
                    value: $viewModel.damage,
                    in: 1...12
                )
                .accessibilityIdentifier("\(accessibilityPrefix).damage")
            }
        }
        .modifier(ConditionalResolverCard(enabled: !isEmbedded))
    }

    private func diceField(
        label: String,
        value: Binding<Int>,
        accessibilityId: String,
        rollAccessibilityId: String,
        onRoll: @escaping () -> Void
    ) -> some View {
        SimulatedDiceFieldRow(
            label: label,
            value: value,
            accessibilityId: accessibilityId,
            rollAccessibilityId: rollAccessibilityId,
            isSimulated: isSimulated,
            onRoll: onRoll
        )
    }
}
