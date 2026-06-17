import SwiftUI
import TabletomeDomain
import TabletomeData

struct UnitMatchupEvaluatorView: View {
    @StateObject private var viewModel: UnitMatchupEvaluatorViewModel
    let ruleSections: [RuleSection]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(
        ruleSections: [RuleSection] = [],
        catalogRepository: any SpearheadCatalogRepository = BundledSpearheadCatalogRepository(),
        attackerPrefill: MatchupUnitPrefill? = nil,
        defenderPrefill: MatchupUnitPrefill? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: catalogRepository,
                attackerPrefill: attackerPrefill,
                defenderPrefill: defenderPrefill
            )
        )
        self.ruleSections = ruleSections
    }

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                EmptyStateView(title: String(localized: "Unavailable"), message: errorMessage)
            } else if viewModel.armies.isEmpty {
                ProgressView()
            } else {
                matchupContent
            }
        }
        .navigationTitle(String(localized: "Unit Matchup"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    viewModel.resetAll()
                }
                .accessibilityIdentifier("matchup.reset")
            }
        }
        .accessibilityIdentifier("matchup.screen")
        .task { await viewModel.load() }
        .onChange(of: viewModel.hitRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.woundRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.saveRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.wardRoll) { _, _ in viewModel.clearResults() }
        .onChange(of: viewModel.damage) { _, _ in viewModel.clearResults() }
    }

    private var matchupContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                introSection
                matchupPanels
                buffsSection
                profileSection
                diceSection
                evaluateButton
                resultsSection
                ruleLinkSection
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
    }

    private var introSection: some View {
        Text(
            "Pick an attacking unit and weapon, then a defending unit. "
                + "Toggle active buffs, roll dice, and evaluate a single attack."
        )
        .font(.callout)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var matchupPanels: some View {
        if horizontalSizeClass == .regular {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                attackerPanel
                vsDivider
                defenderPanel
            }
        } else {
            attackerPanel
            vsDivider
            defenderPanel
        }
    }

    private var vsDivider: some View {
        Text(String(localized: "VS"))
            .font(.title3.bold())
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }

    private var attackerPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Attacker"),
            armyName: viewModel.selectedAttackerArmy?.name ?? "",
            armies: viewModel.armies,
            armyId: $viewModel.attackerArmyId,
            units: viewModel.selectedAttackerArmy?.units ?? [],
            unitId: $viewModel.attackerUnitId,
            weapons: viewModel.evaluableWeapons,
            weaponId: $viewModel.attackerWeaponId,
            showsWeaponPicker: true,
            onArmyChange: viewModel.setAttackerArmy,
            onUnitChange: viewModel.setAttackerUnit,
            onWeaponChange: viewModel.setAttackerWeapon
        )
        .accessibilityIdentifier("matchup.attackerPanel")
    }

    private var defenderPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Defender"),
            armyName: viewModel.selectedDefenderArmy?.name ?? "",
            armies: opposingArmies(forAttackerId: viewModel.attackerArmyId),
            armyId: $viewModel.defenderArmyId,
            units: viewModel.selectedDefenderArmy?.units ?? [],
            unitId: $viewModel.defenderUnitId,
            weaponId: .constant(""),
            onArmyChange: viewModel.setDefenderArmy,
            onUnitChange: viewModel.setDefenderUnit,
            onWeaponChange: { _ in }
        )
        .accessibilityIdentifier("matchup.defenderPanel")
    }

    @ViewBuilder
    private var buffsSection: some View {
        if !viewModel.matchupBuffs.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Active Buffs"))
                    .font(.title3.bold())

                if !viewModel.attackerBuffs.isEmpty {
                    buffGroup(title: String(localized: "Attacker"), buffs: viewModel.attackerBuffs)
                }
                if !viewModel.defenderBuffs.isEmpty {
                    buffGroup(title: String(localized: "Defender"), buffs: viewModel.defenderBuffs)
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
    }

    private func buffGroup(title: String, buffs: [CombatMatchupBuff]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            ForEach(buffs) { buff in
                CombatBuffToggleRow(
                    buff: buff,
                    isOn: viewModel.enabledBuffIds.contains(buff.id)
                ) { enabled in
                    viewModel.toggleBuff(buff, enabled: enabled)
                }
            }
        }
    }

    @ViewBuilder
    private var profileSection: some View {
        if let weapon = viewModel.selectedAttackerWeapon,
           let profile = weapon.numericRollProfile,
           let save = viewModel.selectedDefenderUnit?.save {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "Attack Profile"))
                    .font(.title3.bold())
                Text(
                    "Hit \(profile.hit)+ · Wound \(profile.wound)+ · Rend \(profile.rend) · "
                        + "Damage \(viewModel.damage) vs Save \(save)+"
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                if weapon.damage != "\(viewModel.damage)" {
                    Stepper(
                        String(localized: "Damage \(viewModel.damage)"),
                        value: $viewModel.damage,
                        in: 1...6
                    )
                    .accessibilityIdentifier("matchup.damage")
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
    }

    private var diceSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Dice Rolled"))
                .font(.title3.bold())
            DiceValuePicker(
                label: String(localized: "Hit roll"),
                value: $viewModel.hitRoll,
                accessibilityId: "matchup.hitRoll"
            )
            DiceValuePicker(
                label: String(localized: "Wound roll"),
                value: $viewModel.woundRoll,
                accessibilityId: "matchup.woundRoll"
            )
            DiceValuePicker(
                label: String(localized: "Save roll"),
                value: $viewModel.saveRoll,
                accessibilityId: "matchup.saveRoll"
            )
            if viewModel.activeWardTarget != nil {
                DiceValuePicker(
                    label: String(localized: "Ward roll"),
                    value: $viewModel.wardRoll,
                    accessibilityId: "matchup.wardRoll"
                )
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var evaluateButton: some View {
        PrimaryButton(
            title: viewModel.evaluateDamageButtonTitle,
            accessibilityId: "matchup.evaluate"
        ) {
            viewModel.evaluate()
        }
        .disabled(!viewModel.canEvaluate)
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
            .accessibilityIdentifier("matchup.results")
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
            .accessibilityIdentifier("matchup.relatedRule")
        }
    }

    private func opposingArmies(forAttackerId attackerId: String) -> [SpearheadArmy] {
        viewModel.armies.filter { $0.id != attackerId }
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
    }
}
