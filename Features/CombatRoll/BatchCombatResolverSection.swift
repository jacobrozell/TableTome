import SwiftUI
import TabletomeDomain

struct BatchCombatResolverSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    var defenderName: String?
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        if combatViewModel.canEvaluate {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                header
                batchInputs
                saveReference
                if let evaluation = batchViewModel.evaluation {
                    outcomeSection(evaluation)
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .accessibilityIdentifier("\(accessibilityPrefix).batchCombat")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Resolve Attack Batch"))
                .font(.subheadline.weight(.semibold))
            Text(
                String(
                    localized: """
                    Enter what you rolled at the table: hits, then wounds, then how many saves failed.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var batchInputs: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            batchStepper(
                label: String(localized: "Successful hits"),
                value: $batchViewModel.successfulHits,
                range: 0...batchViewModel.hitDiceCount,
                accessibilityId: "\(accessibilityPrefix).batchCombat.hits",
                hint: String(localized: "Out of \(batchViewModel.hitDiceCount) hit dice")
            )

            if batchViewModel.successfulHits > 0 {
                batchStepper(
                    label: String(localized: "Wounds caused"),
                    value: $batchViewModel.successfulWounds,
                    range: 0...batchViewModel.successfulHits,
                    accessibilityId: "\(accessibilityPrefix).batchCombat.wounds",
                    hint: String(localized: "After rolling wound dice for each hit")
                )
            }

            if batchViewModel.successfulWounds > 0, !batchViewModel.mortalDamage {
                batchStepper(
                    label: String(localized: "Failed saves"),
                    value: $batchViewModel.failedSaves,
                    range: 0...batchViewModel.successfulWounds,
                    accessibilityId: "\(accessibilityPrefix).batchCombat.failedSaves",
                    hint: String(localized: "Wounds that did not save")
                )
            }

            if batchViewModel.wardTarget != nil, batchViewModel.failedSaves > 0 {
                batchStepper(
                    label: String(localized: "Warded off"),
                    value: $batchViewModel.wardNegatedCount,
                    range: 0...batchViewModel.failedSaves,
                    accessibilityId: "\(accessibilityPrefix).batchCombat.warded",
                    hint: String(
                        localized: "Failed saves ignored by Ward \(batchViewModel.wardTarget ?? 0)+"
                    )
                )
            }

            if batchViewModel.usesVariableDamage {
                variableDamageInputs
            }

            Button(String(localized: "Clear batch")) {
                batchViewModel.resetCounts()
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.borderless)
            .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.reset")
        }
    }

    private var variableDamageInputs: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Toggle(isOn: $batchViewModel.usesManualTotalDamage) {
                Text(String(localized: "Enter total damage manually"))
                    .font(.caption.weight(.semibold))
            }
            .toggleStyle(.switch)
            .onChange(of: batchViewModel.usesManualTotalDamage) { _, _ in
                batchViewModel.evaluate()
            }

            if batchViewModel.usesManualTotalDamage {
                Stepper(
                    String(localized: "Total damage: \(batchViewModel.manualTotalDamage)"),
                    value: $batchViewModel.manualTotalDamage,
                    in: 0...999
                )
                .onChange(of: batchViewModel.manualTotalDamage) { _, _ in
                    batchViewModel.evaluate()
                }
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.manualDamage")
            } else {
                Stepper(
                    String(localized: "Damage per wound: \(batchViewModel.damagePerWound)"),
                    value: $batchViewModel.damagePerWound,
                    in: 1...12
                )
                .onChange(of: batchViewModel.damagePerWound) { _, _ in
                    batchViewModel.evaluate()
                }
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.damagePerWound")
            }
        }
    }

    private var saveReference: some View {
        Group {
            if batchViewModel.successfulWounds > 0, !batchViewModel.mortalDamage {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(.secondary)
                    Text(
                        String(
                            localized: """
                            Save \(batchViewModel.saveTarget)+ with \(penetrationLabel) \
                            \(penetrationValue) → roll \(batchViewModel.saveNeededOnDice)+ on each save dice
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            } else if batchViewModel.mortalDamage, batchViewModel.successfulWounds > 0 {
                Text(String(localized: "Mortal damage — skip save rolls for these wounds."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: combatViewModel.gameSystemId)
    }

    private var penetrationLabel: String {
        usesWh40kRules ? String(localized: "AP") : String(localized: "Rend")
    }

    private var penetrationValue: String {
        if usesWh40kRules {
            return "\(batchViewModel.rend)"
        }
        return rendLabel
    }

    private var rendLabel: String {
        batchViewModel.rend >= 0 ? "+\(batchViewModel.rend)" : "\(batchViewModel.rend)"
    }

    private func outcomeSection(_ evaluation: BatchCombatRollEvaluation) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(evaluation.outcomeHeadline)
                    .font(.headline)
                Spacer(minLength: 0)
                Text("\(evaluation.totalDamage)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(evaluation.totalDamage > 0 ? .orange : .secondary)
            }

            ForEach(evaluation.summarySteps) { step in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Text(step.title)
                        .font(.caption.weight(.semibold))
                        .frame(width: 88, alignment: .leading)
                    Text(step.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if evaluation.totalDamage > 0,
               let onApplyDamage,
               let defenderName {
                Button {
                    let context = CombatBatchLogContext(
                        attackerUnitName: combatViewModel.selectedAttackerUnit?.name ?? "",
                        defenderUnitName: defenderName,
                        weaponName: combatViewModel.selectedAttackerWeapon?.name ?? "",
                        hits: batchViewModel.successfulHits,
                        wounds: batchViewModel.successfulWounds,
                        failedSaves: batchViewModel.failedSaves,
                        damageDealt: evaluation.totalDamage
                    )
                    onApplyDamage(evaluation.totalDamage, context)
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(
                            String(localized: "Apply \(evaluation.totalDamage) damage to \(defenderName)"),
                            systemImage: "heart.slash.fill"
                        )
                        .font(.subheadline.weight(.semibold))
                        if let defenderWoundsRemaining {
                            Text(
                                String(
                                    localized: """
                                    Wounds remaining: \(defenderWoundsRemaining) → \
                                    \(max(0, defenderWoundsRemaining - evaluation.totalDamage))
                                    """
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.applyDamage")
            }
        }
    }

    private func batchStepper(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        accessibilityId: String,
        hint: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Stepper(
                String(localized: "\(label): \(value.wrappedValue)"),
                value: value,
                in: range
            )
            .onChange(of: value.wrappedValue) { _, _ in
                batchViewModel.evaluate()
            }
            .accessibilityIdentifier(accessibilityId)
            Text(hint)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
