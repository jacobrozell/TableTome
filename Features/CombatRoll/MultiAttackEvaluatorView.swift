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
                    title: String(localized: "Evaluate Attack \(viewModel.results.count + 1) of \(viewModel.attackCount)"),
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
            SectionHeader(title: String(localized: "Multi-Attack: \(weaponName)"), systemImage: "repeat")
            Stepper(
                String(localized: "\(viewModel.attackCount) attacks"),
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
        .surfaceCard()
    }

    private var diceSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Dice for Next Attack"), systemImage: "dice.fill")
            DiceValuePicker(label: String(localized: "Hit"), value: $viewModel.hitRoll, accessibilityId: "multiAttack.hitRoll")
            DiceValuePicker(label: String(localized: "Wound"), value: $viewModel.woundRoll, accessibilityId: "multiAttack.woundRoll")
            DiceValuePicker(label: String(localized: "Save"), value: $viewModel.saveRoll, accessibilityId: "multiAttack.saveRoll")
            Stepper(String(localized: "Damage \(viewModel.damage)"), value: $viewModel.damage, in: 1...12)
        }
        .surfaceCard()
    }

    @ViewBuilder
    private var weaponOptionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: String(localized: "Weapon Rules"), systemImage: "bolt.fill")
            rollOptionToggle(String(localized: "Crit (Auto-wound)"), keyPath: \.critAutoWound, id: "multiAttack.critAutoWound")
            rollOptionToggle(String(localized: "Crit (Mortal)"), keyPath: \.critMortal, id: "multiAttack.critMortal")
            rollOptionToggle(String(localized: "Mortal damage (skip save)"), keyPath: \.mortalDamage, id: "multiAttack.mortalDamage")
        }
        .surfaceCard()
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
                .font(.subheadline)
        }
        .toggleStyle(.switch)
        .accessibilityIdentifier(id)
    }

    private func attackResult(_ evaluation: AttackRollEvaluation, attackNumber: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: String(localized: "Attack \(attackNumber)"), systemImage: "number")
            ForEach(evaluation.steps) { step in
                RollStepCard(step: step)
            }
            DamageSummaryCard(
                damage: evaluation.damageDealt,
                accessibilityId: "multiAttack.damage.\(attackNumber)"
            )
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
                    .monospacedDigit()
                    .foregroundStyle(viewModel.totalDamage > 0 ? .orange : .secondary)
                    .contentTransition(.numericText())
            }
            if viewModel.isSequenceComplete {
                Text(String(localized: "All \(viewModel.attackCount) attacks resolved."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(String(localized: "Roll Again")) {
                    viewModel.resetSequence()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("multiAttack.reset")
            }
            if viewModel.results.count > 1 {
                Divider()
                ForEach(viewModel.results) { result in
                    HStack {
                        Text(String(localized: "Attack \(result.id)"))
                        Spacer()
                        Text(String(localized: "\(result.evaluation.damageDealt) dmg"))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .font(.caption)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("multiAttack.summary")
    }
}
