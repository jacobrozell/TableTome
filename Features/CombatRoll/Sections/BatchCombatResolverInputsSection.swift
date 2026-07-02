import SwiftUI
import TabletomeDomain

struct BatchCombatResolverInputsSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @Binding var confirmedZeroHits: Bool
    @Binding var confirmedZeroWounds: Bool
    let accessibilityPrefix: String
    let activeStep: BatchCombatFlowStep
    let hitsStepComplete: Bool
    let woundsStepComplete: Bool
    let savesStepComplete: Bool
    let wardStepComplete: Bool
    let wardStepNumber: Int
    let woundsStepHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            CombatBatchStepRow(
                stepNumber: 1,
                title: String(localized: "Successful hits"),
                value: $batchViewModel.successfulHits,
                range: 0...batchViewModel.hitDiceCount,
                hint: String(localized: "Out of \(batchViewModel.hitDiceCount) hit dice you rolled"),
                isActive: activeStep == .hits,
                isComplete: hitsStepComplete,
                isLocked: false,
                accessibilityId: "\(accessibilityPrefix).batchCombat.hits",
                onChange: {
                    if batchViewModel.successfulHits > 0 {
                        confirmedZeroHits = false
                    }
                    batchViewModel.evaluate()
                }
            )

            if batchViewModel.successfulHits == 0, !confirmedZeroHits {
                Button(String(localized: "No hits landed — skip damage")) {
                    confirmedZeroHits = true
                    batchViewModel.successfulWounds = 0
                    batchViewModel.failedSaves = 0
                    batchViewModel.wardNegatedCount = 0
                    batchViewModel.evaluate()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.zeroHits")
            }

            CombatBatchStepRow(
                stepNumber: 2,
                title: String(localized: "Wounds caused"),
                value: $batchViewModel.successfulWounds,
                range: 0...max(batchViewModel.successfulHits, 1),
                hint: woundsStepHint,
                isActive: activeStep == .wounds,
                isComplete: woundsStepComplete,
                isLocked: !hitsStepComplete,
                accessibilityId: "\(accessibilityPrefix).batchCombat.wounds",
                onChange: {
                    if batchViewModel.successfulWounds > 0 {
                        confirmedZeroWounds = false
                    }
                    batchViewModel.evaluate()
                }
            )

            if batchViewModel.successfulHits > 0,
               batchViewModel.successfulWounds == 0,
               !confirmedZeroWounds,
               hitsStepComplete {
                Button(String(localized: "No wounds caused — skip saves")) {
                    confirmedZeroWounds = true
                    batchViewModel.failedSaves = 0
                    batchViewModel.wardNegatedCount = 0
                    batchViewModel.evaluate()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.zeroWounds")
            }

            if !batchViewModel.mortalDamage {
                CombatBatchStepRow(
                    stepNumber: 3,
                    title: String(localized: "Failed saves"),
                    value: $batchViewModel.failedSaves,
                    range: 0...max(batchViewModel.successfulWounds, 1),
                    hint: String(
                        localized: "Wounds the defender did not save (need \(batchViewModel.saveNeededOnDice)+ on each save dice)"
                    ),
                    isActive: activeStep == .saves,
                    isComplete: savesStepComplete,
                    isLocked: !woundsStepComplete,
                    accessibilityId: "\(accessibilityPrefix).batchCombat.failedSaves",
                    onChange: { batchViewModel.evaluate() }
                )
            }

            if batchViewModel.wardTarget != nil {
                CombatBatchStepRow(
                    stepNumber: wardStepNumber,
                    title: String(localized: "Warded off"),
                    value: $batchViewModel.wardNegatedCount,
                    range: 0...max(batchViewModel.failedSaves, 1),
                    hint: String(
                        localized: """
                        After a save fails, roll Ward \(batchViewModel.wardTarget ?? 0)+ — a success ignores that wound.
                        """
                    ),
                    isActive: activeStep == .ward,
                    isComplete: wardStepComplete,
                    isLocked: !savesStepComplete,
                    accessibilityId: "\(accessibilityPrefix).batchCombat.warded",
                    onChange: { batchViewModel.evaluate() }
                )
            }

            if batchViewModel.usesVariableDamage {
                variableDamageInputs
            }

            if confirmedZeroHits || confirmedZeroWounds {
                Label(
                    confirmedZeroHits
                        ? String(localized: "No hits — this attack deals no damage.")
                        : String(localized: "No wounds — this attack deals no damage."),
                    systemImage: "checkmark.circle.fill"
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }

            Button(String(localized: "Clear and start over")) {
                confirmedZeroHits = false
                confirmedZeroWounds = false
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
                    String(localized: "Damage per unsaved wound: \(batchViewModel.damagePerWound)"),
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
}
