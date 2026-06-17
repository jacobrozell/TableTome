import SwiftUI
import TabletomeDomain

struct CombatRollEvaluatorView: View {
    @StateObject private var viewModel: CombatRollEvaluatorViewModel
    let ruleSections: [RuleSection]

    init(ruleSections: [RuleSection] = [], prefilledWeapon: SpearheadWeapon? = nil) {
        let model = CombatRollEvaluatorViewModel()
        if let prefilledWeapon {
            model.apply(weapon: prefilledWeapon)
        }
        _viewModel = StateObject(wrappedValue: model)
        self.ruleSections = ruleSections
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                introSection
                weaponProfileSection
                diceSection
                modifiersSection
                weaponOptionsSection
                evaluateButton
                NavigationLink {
                    UnitMatchupEvaluatorView(ruleSections: ruleSections)
                } label: {
                    Label(String(localized: "Unit Matchup"), systemImage: "arrow.left.arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("rollEvaluator.unitMatchup")
                resultsSection
                ruleLinkSection
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Roll Evaluator"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    viewModel.resetAll()
                }
                .accessibilityIdentifier("rollEvaluator.reset")
            }
        }
        .accessibilityIdentifier("rollEvaluator.screen")
        .onChange(of: viewModel.hitRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.woundRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.saveRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.hitTarget) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.woundTarget) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.saveTarget) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.rend) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.damage) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.hitModifier) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.woundModifier) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.saveModifier) { _, _ in viewModel.clearResults() }
    }

    private var introSection: some View {
        Text(
            "Enter your weapon profile and the dice you rolled. "
                + "Tabletome walks through hit, wound, save, and damage per the core combat sequence."
        )
        .font(.callout)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var weaponProfileSection: some View {
        formSection(title: String(localized: "Weapon Profile")) {
            profileStepper(
                label: String(localized: "Hit"),
                value: $viewModel.hitTarget,
                range: 2...6,
                display: { "\($0)+" },
                id: "rollEvaluator.hitTarget"
            )
            profileStepper(
                label: String(localized: "Wound"),
                value: $viewModel.woundTarget,
                range: 2...6,
                display: { "\($0)+" },
                id: "rollEvaluator.woundTarget"
            )
            profileStepper(
                label: String(localized: "Save"),
                value: $viewModel.saveTarget,
                range: 2...6,
                display: { "\($0)+" },
                id: "rollEvaluator.saveTarget"
            )
            profileStepper(
                label: String(localized: "Rend"),
                value: $viewModel.rend,
                range: -3...0,
                display: { "\($0)" },
                id: "rollEvaluator.rend"
            )
            profileStepper(
                label: String(localized: "Damage"),
                value: $viewModel.damage,
                range: 1...6,
                display: { "\($0)" },
                id: "rollEvaluator.damage"
            )
        }
    }

    private var diceSection: some View {
        formSection(title: String(localized: "Dice Rolled")) {
            DiceValuePicker(
                label: String(localized: "Hit roll"),
                value: $viewModel.hitRoll,
                accessibilityId: "rollEvaluator.hitRoll"
            )
            DiceValuePicker(
                label: String(localized: "Wound roll"),
                value: $viewModel.woundRoll,
                accessibilityId: "rollEvaluator.woundRoll"
            )
            DiceValuePicker(
                label: String(localized: "Save roll"),
                value: $viewModel.saveRoll,
                accessibilityId: "rollEvaluator.saveRoll"
            )
        }
    }

    private var modifiersSection: some View {
        formSection(title: String(localized: "Modifiers")) {
            Text(String(localized: "Hit and wound modifiers are capped at +1 / −1 after summing all sources."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            modifierStepper(
                label: String(localized: "Hit modifier"),
                value: $viewModel.hitModifier,
                id: "rollEvaluator.hitModifier"
            )
            modifierStepper(
                label: String(localized: "Wound modifier"),
                value: $viewModel.woundModifier,
                id: "rollEvaluator.woundModifier"
            )
            modifierStepper(
                label: String(localized: "Save modifier"),
                value: $viewModel.saveModifier,
                id: "rollEvaluator.saveModifier"
            )
        }
    }

    private var weaponOptionsSection: some View {
        formSection(title: String(localized: "Weapon Rules")) {
            rollOptionToggle(String(localized: "Crit (Auto-wound)"), keyPath: \.critAutoWound, id: "rollEvaluator.critAutoWound")
            rollOptionToggle(String(localized: "Crit (Mortal)"), keyPath: \.critMortal, id: "rollEvaluator.critMortal")
            rollOptionToggle(String(localized: "Mortal damage (skip save)"), keyPath: \.mortalDamage, id: "rollEvaluator.mortalDamage")
        }
    }

    private func rollOptionToggle(
        _ label: String,
        keyPath: WritableKeyPath<CombatRollOptions, Bool>,
        id: String
    ) -> some View {
        Toggle(isOn: Binding(
            get: { viewModel.rollOptions[keyPath: keyPath] },
            set: {
                viewModel.rollOptions[keyPath: keyPath] = $0
                viewModel.clearResults()
            }
        )) {
            Text(label)
        }
        .accessibilityIdentifier(id)
    }

    private var evaluateButton: some View {
        PrimaryButton(title: String(localized: "Evaluate Attack"), accessibilityId: "rollEvaluator.evaluate") {
            viewModel.evaluate()
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if let evaluation = viewModel.evaluation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Result"))
                    .font(.title3.bold())

                ForEach(evaluation.steps) { step in
                    RollStepCard(step: step)
                }

                damageSummary(evaluation.damageDealt)
            }
            .accessibilityIdentifier("rollEvaluator.results")
        }
    }

    @ViewBuilder
    private var ruleLinkSection: some View {
        if let combatSection = ruleSections.first(where: { $0.id == "combat-sequence" }) {
            NavigationLink {
                RuleSectionDetailView(section: combatSection, allSections: ruleSections)
            } label: {
                Label(combatSection.title, systemImage: "doc.text")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityLabel(String(localized: "Related rule: \(combatSection.title)"))
            .accessibilityIdentifier("rollEvaluator.relatedRule")
        }
    }

    private func damageSummary(_ damage: Int) -> some View {
        HStack {
            Image(systemName: damage > 0 ? "bolt.fill" : "shield.fill")
                .foregroundStyle(damage > 0 ? .orange : .green)
                .accessibilityHidden(true)
            Text(
                damage > 0
                    ? String(localized: "\(damage) damage to allocate")
                    : String(localized: "No damage dealt")
            )
            .font(.headline)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("rollEvaluator.damageSummary")
    }

    private func formSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(title)
                .font(.title3.bold())
            content()
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private func profileStepper(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        display: (Int) -> String,
        id: String
    ) -> some View {
        Stepper("\(label) \(display(value.wrappedValue))", value: value, in: range)
            .accessibilityIdentifier(id)
    }

    private func modifierStepper(label: String, value: Binding<Int>, id: String) -> some View {
        Stepper(modifierLabel(label: label, value: value.wrappedValue), value: value, in: -3...3)
            .accessibilityIdentifier(id)
    }

    private func modifierLabel(label: String, value: Int) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(label) \(sign)\(value)"
    }
}
