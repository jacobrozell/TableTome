import SwiftUI
import TabletomeDomain

struct BatchCombatResolverSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    var defenderName: String?
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    @State private var confirmedZeroHits = false
    @State private var confirmedZeroWounds = false

    var body: some View {
        if combatViewModel.canEvaluate {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                header
                flowPills
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
            Text(String(localized: "Enter table results"))
                .font(.headline)
            if batchViewModel.hitDiceCount > 0 {
                Text(
                    String(
                        localized: """
                        Step 1: Roll \(batchViewModel.hitDiceCount) hit dice at the table. \
                        Then enter how many scored a hit below — work top to bottom through wounds and saves.
                        """
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(
                    String(
                        localized: """
                        After rolling hit dice at the table, enter each count below. \
                        Work top to bottom — hits, then wounds, then failed saves.
                        """
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var flowPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                flowPill(String(localized: "Hits"), step: .hits)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Wounds"), step: .wounds)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Saves"), step: .saves)
                if batchViewModel.wardTarget != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                    flowPill(String(localized: "Ward"), step: .ward)
                }
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Damage"), step: .damage)
            }
        }
        .accessibilityHidden(true)
    }

    private func flowPill(_ label: String, step: BatchFlowStep) -> some View {
        let isActive = activeStep == step
        let isDone = stepIsComplete(step)
        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                isActive ? Color.accentColor.opacity(0.2) : (isDone ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemFill)),
                in: Capsule()
            )
            .foregroundStyle(isActive ? Color.accentColor : .secondary)
    }

    private var batchInputs: some View {
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

    private var woundsStepHint: String {
        if batchViewModel.successfulHits == 0 {
            return String(localized: "Enter 0 if no hits became wounds")
        }
        return String(localized: "How many hits became wounds after wound rolls")
    }

    private var hitsStepComplete: Bool {
        batchViewModel.successfulHits > 0 || confirmedZeroHits
    }

    private var woundsStepComplete: Bool {
        guard hitsStepComplete, !confirmedZeroHits else { return confirmedZeroHits }
        return batchViewModel.successfulWounds > 0
            || batchViewModel.failedSaves > 0
            || batchViewModel.wardNegatedCount > 0
            || confirmedZeroWounds
    }

    private var savesStepComplete: Bool {
        guard woundsStepComplete, !confirmedZeroHits, !confirmedZeroWounds else {
            return confirmedZeroHits || confirmedZeroWounds
        }
        return batchViewModel.failedSaves > 0
            || batchViewModel.wardNegatedCount > 0
            || batchViewModel.mortalDamage
            || batchViewModel.successfulWounds == 0
    }

    private var wardStepComplete: Bool {
        guard savesStepComplete, !confirmedZeroHits, !confirmedZeroWounds else {
            return confirmedZeroHits || confirmedZeroWounds
        }
        return batchViewModel.wardNegatedCount > 0 || batchViewModel.wardTarget == nil
    }

    private var wardStepNumber: Int {
        batchViewModel.mortalDamage ? 3 : 4
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

    private var saveReference: some View {
        Group {
            if batchViewModel.successfulWounds > 0, !batchViewModel.mortalDamage {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(Color.accentColor)
                    Text(
                        BatchCombatSaveHint.saveReferenceLine(
                            saveTarget: batchViewModel.saveTarget,
                            rend: batchViewModel.rend,
                            saveNeededOnDice: batchViewModel.saveNeededOnDice,
                            usesWh40kRules: usesWh40kRules
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            } else if batchViewModel.mortalDamage, batchViewModel.successfulWounds > 0 {
                Label(
                    String(localized: "Mortal damage — skip save rolls for these wounds."),
                    systemImage: "bolt.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: combatViewModel.gameSystemId)
    }

    private func outcomeSection(_ evaluation: BatchCombatRollEvaluation) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Damage to allocate"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(evaluation.outcomeHeadline)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text("\(evaluation.totalDamage)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(evaluation.totalDamage > 0 ? .orange : .secondary)
                    .contentTransition(.numericText())
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                evaluation.totalDamage > 0 ? Color.orange.opacity(0.12) : Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
            )

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "How we got here"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
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
                        .font(.headline)
                        if let defenderWoundsRemaining {
                            Text(
                                String(
                                    localized: """
                                    Wounds remaining: \(defenderWoundsRemaining) → \
                                    \(max(0, defenderWoundsRemaining - evaluation.totalDamage))
                                    """
                                )
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.applyDamage")
            }
        }
    }

    private enum BatchFlowStep {
        case hits, wounds, saves, ward, damage
    }

    private var activeStep: BatchFlowStep {
        if !hitsStepComplete { return .hits }
        if !woundsStepComplete { return .wounds }
        if !batchViewModel.mortalDamage, !savesStepComplete { return .saves }
        if batchViewModel.wardTarget != nil, !wardStepComplete { return .ward }
        return .damage
    }

    private func stepIsComplete(_ step: BatchFlowStep) -> Bool {
        switch step {
        case .hits: hitsStepComplete
        case .wounds: woundsStepComplete
        case .saves: savesStepComplete
        case .ward: wardStepComplete
        case .damage: (batchViewModel.evaluation?.totalDamage ?? 0) >= 0 && hitsStepComplete
        }
    }
}
