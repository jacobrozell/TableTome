import SwiftUI
import TabletomeDomain

struct MultiAttackEvaluatorView: View {
    @ObservedObject var viewModel: MultiAttackEvaluatorViewModel
    let weaponName: String
    let ruleSections: [RuleSection]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            headerSection
            if !viewModel.isSequenceComplete {
                diceSection
                weaponOptionsSection
                PrimaryButton(
                    title: "Evaluate Attack \(viewModel.results.count + 1) of \(viewModel.attackCount)",
                    accessibilityId: "multiAttack.evaluate"
                ) {
                    viewModel.evaluateCurrentAttack()
                }
            }
            if let last = viewModel.lastEvaluation, viewModel.results.count == viewModel.currentAttackIndex {
                attackResult(last, attackNumber: viewModel.results.count)
            }
            if !viewModel.results.isEmpty {
                summarySection
            }
        }
        .accessibilityIdentifier("multiAttack.section")
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Multi-Attack: \(weaponName)")
                .font(.headline)
            Stepper(
                "\(viewModel.attackCount) attacks",
                value: $viewModel.attackCount,
                in: 1...20
            )
            .accessibilityIdentifier("multiAttack.attackCount")
            Text(
                "Hit \(viewModel.hitTarget)+ · Wound \(viewModel.woundTarget)+ · "
                    + "Rend \(viewModel.rend) · Damage \(viewModel.damage) vs Save \(viewModel.saveTarget)+"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var diceSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Dice for Next Attack"))
                .font(.subheadline.bold())
            DiceValuePicker(label: String(localized: "Hit"), value: $viewModel.hitRoll, accessibilityId: "multiAttack.hitRoll")
            DiceValuePicker(label: String(localized: "Wound"), value: $viewModel.woundRoll, accessibilityId: "multiAttack.woundRoll")
            DiceValuePicker(label: String(localized: "Save"), value: $viewModel.saveRoll, accessibilityId: "multiAttack.saveRoll")
            Stepper("Damage \(viewModel.damage)", value: $viewModel.damage, in: 1...12)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    @ViewBuilder
    private var weaponOptionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Weapon Rules"))
                .font(.subheadline.bold())
            rollOptionToggle(String(localized: "Crit (Auto-wound)"), keyPath: \.critAutoWound, id: "multiAttack.critAutoWound")
            rollOptionToggle(String(localized: "Crit (Mortal)"), keyPath: \.critMortal, id: "multiAttack.critMortal")
            rollOptionToggle(String(localized: "Mortal damage (skip save)"), keyPath: \.mortalDamage, id: "multiAttack.mortalDamage")
        }
        .font(.subheadline)
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private func rollOptionToggle(
        _ label: String,
        keyPath: WritableKeyPath<CombatRollOptions, Bool>,
        id: String
    ) -> some View {
        Toggle(isOn: Binding(
            get: { viewModel.rollOptions[keyPath: keyPath] },
            set: { viewModel.rollOptions[keyPath: keyPath] = $0 }
        )) {
            Text(label)
        }
        .accessibilityIdentifier(id)
    }

    private func attackResult(_ evaluation: AttackRollEvaluation, attackNumber: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Attack \(attackNumber)")
                .font(.subheadline.bold())
            ForEach(evaluation.steps) { step in
                RollStepCard(step: step)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text(String(localized: "Total Damage"))
                    .font(.headline)
                Spacer()
                Text("\(viewModel.totalDamage)")
                    .font(.title2.bold())
                    .foregroundStyle(viewModel.totalDamage > 0 ? .orange : .secondary)
            }
            if viewModel.isSequenceComplete {
                Text("All \(viewModel.attackCount) attacks resolved.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(String(localized: "Roll Again")) {
                    viewModel.resetSequence()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("multiAttack.reset")
            }
            ForEach(viewModel.results) { result in
                HStack {
                    Text("Attack \(result.id)")
                    Spacer()
                    Text("\(result.evaluation.damageDealt) dmg")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("multiAttack.summary")
    }
}
