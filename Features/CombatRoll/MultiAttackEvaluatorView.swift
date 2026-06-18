import SwiftUI
import TabletomeDomain

struct MultiAttackEvaluatorView: View {
    @ObservedObject var viewModel: MultiAttackEvaluatorViewModel
    let weaponName: String
    let ruleSections: [RuleSection]
    let isSimulated: Bool
    var gameSystemId: String = "aos-spearhead"

    @State private var batchHitCount = 1

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId)
    }

    init(
        viewModel: MultiAttackEvaluatorViewModel,
        weaponName: String,
        ruleSections: [RuleSection],
        isSimulated: Bool = false,
        gameSystemId: String = "aos-spearhead"
    ) {
        self.viewModel = viewModel
        self.weaponName = weaponName
        self.ruleSections = ruleSections
        self.isSimulated = isSimulated
        self.gameSystemId = gameSystemId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            headerSection
            if !viewModel.isSequenceComplete {
                diceSection
                weaponOptionsSection
                if isSimulated {
                    PrimaryButton(
                        title: String(
                            localized: "Roll Attack \(viewModel.results.count + 1) of \(viewModel.attackCount)"
                        ),
                        accessibilityId: "multiAttack.roll.attack"
                    ) {
                        viewModel.rollCurrentAttack()
                    }
                    if viewModel.attackCount > 1, !viewModel.isSequenceComplete {
                        Button(String(localized: "Roll all remaining attacks")) {
                            viewModel.rollAllRemainingAttacks()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .accessibilityIdentifier("multiAttack.rollAll")
                    }
                    Button(
                        String(localized: "Evaluate Attack \(viewModel.results.count + 1) of \(viewModel.attackCount)")
                    ) {
                        viewModel.evaluateCurrentAttack()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("multiAttack.evaluate")
                    .accessibilityHint(String(localized: "Uses current dice values without rolling again"))
                } else {
                    batchPhysicalSection
                    PrimaryButton(
                        title: String(localized: "Evaluate Attack \(viewModel.results.count + 1) of \(viewModel.attackCount)"),
                        accessibilityId: "multiAttack.evaluate"
                    ) {
                        viewModel.evaluateCurrentAttack()
                    }
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

    private var batchPhysicalSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(
                String(
                    localized: "After rolling all hit dice at the table, enter how many hits succeeded, then resolve with your wound/save dice below."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Stepper(
                String(localized: "Successful hits: \(min(viewModel.attackCount, max(1, batchHitCount)))"),
                value: $batchHitCount,
                in: 1...max(1, viewModel.attacksRemaining)
            )
            .accessibilityIdentifier("multiAttack.batchHitCount")

            Button(String(localized: "Resolve \(min(batchHitCount, viewModel.attacksRemaining)) hits")) {
                viewModel.resolveBatchHits(batchHitCount)
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("multiAttack.resolveBatch")
        }
        .surfaceCard()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: String(localized: "Multi-Attack: \(weaponName)"), systemImage: "repeat")

            CombatRollCountBanner(
                plan: viewModel.hitDicePlan,
                accessibilityPrefix: "multiAttack"
            )

            DeployedModelCountStepper(
                modelCount: $viewModel.deployedModelCount,
                warscrollModelCount: viewModel.currentUnitModelCount,
                usesVariableAttacks: viewModel.usesVariableAttacks,
                onChange: {
                    viewModel.syncAttackCountFromDeployment()
                },
                accessibilityPrefix: "multiAttack"
            )

            Text(
                usesWh40kRules
                    ? "Hit \(viewModel.hitTarget)+ · Wound \(viewModel.woundTarget)+ · AP \(viewModel.rend) · Damage \(viewModel.damage) vs Save \(viewModel.saveTarget)+"
                    : "Hit \(viewModel.hitTarget)+ · Wound \(viewModel.woundTarget)+ · Rend \(viewModel.rend) · Damage \(viewModel.damage) vs Save \(viewModel.saveTarget)+"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .surfaceCard()
    }

    private var diceSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Dice for Next Attack"), systemImage: "dice.fill")
            if isSimulated {
                SimulatedDiceHint()
                if !viewModel.lastRolls.isEmpty {
                    SimulatedRollSummaryView(rolls: viewModel.lastRolls)
                }
            }
            SimulatedDiceFieldRow(
                label: String(localized: "Hit"),
                value: $viewModel.hitRoll,
                accessibilityId: "multiAttack.hitRoll",
                rollAccessibilityId: "multiAttack.roll.hit",
                isSimulated: isSimulated,
                onRoll: { viewModel.rollHit() }
            )
            SimulatedDiceFieldRow(
                label: String(localized: "Wound"),
                value: $viewModel.woundRoll,
                accessibilityId: "multiAttack.woundRoll",
                rollAccessibilityId: "multiAttack.roll.wound",
                isSimulated: isSimulated,
                onRoll: { viewModel.rollWound() }
            )
            SimulatedDiceFieldRow(
                label: String(localized: "Save"),
                value: $viewModel.saveRoll,
                accessibilityId: "multiAttack.saveRoll",
                rollAccessibilityId: "multiAttack.roll.save",
                isSimulated: isSimulated,
                onRoll: { viewModel.rollSave() }
            )
            if viewModel.wardTarget != nil, !usesWh40kRules {
                SimulatedDiceFieldRow(
                    label: String(localized: "Ward"),
                    value: $viewModel.wardRoll,
                    accessibilityId: "multiAttack.wardRoll",
                    rollAccessibilityId: "multiAttack.roll.ward",
                    isSimulated: isSimulated,
                    onRoll: { viewModel.rollWard() }
                )
            }
            if viewModel.hasFixedDamage {
                Stepper(String(localized: "Damage \(viewModel.damage)"), value: $viewModel.damage, in: 1...12)
            } else if isSimulated {
                Text(String(localized: "Damage is rolled when the attack succeeds."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .surfaceCard()
    }

    @ViewBuilder
    private var weaponOptionsSection: some View {
        if usesWh40kRules {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: String(localized: "Weapon Rules"), systemImage: "bolt.fill")
                rollOptionToggle(
                    String(localized: "Mortal damage (skip save)"),
                    keyPath: \.mortalDamage,
                    id: "multiAttack.mortalDamage"
                )
            }
            .surfaceCard()
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: String(localized: "Weapon Rules"), systemImage: "bolt.fill")
                rollOptionToggle(String(localized: "Crit (Auto-wound)"), keyPath: \.critAutoWound, id: "multiAttack.critAutoWound")
                rollOptionToggle(String(localized: "Crit (Mortal)"), keyPath: \.critMortal, id: "multiAttack.critMortal")
                rollOptionToggle(String(localized: "Mortal damage (skip save)"), keyPath: \.mortalDamage, id: "multiAttack.mortalDamage")
            }
            .surfaceCard()
        }
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
