import SwiftUI
import TabletomeDomain

struct CombatResolverPanel: View {
    enum Presentation {
        case standalone
        case embeddedInBattleTracker
    }

    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool

    let ruleSections: [RuleSection]
    let presentation: Presentation
    var attackerPlayerName: String?
    var defenderPlayerName: String?
    let onSyncMultiAttack: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var diceInputMode: DiceInputMode {
        get { DiceInputMode(rawValue: diceInputModeRaw) ?? .physical }
        nonmutating set { diceInputModeRaw = newValue.rawValue }
    }

    private var isSimulated: Bool { diceInputMode == .simulated }
    private var locksArmies: Bool { presentation == .embeddedInBattleTracker }
    private var isEmbedded: Bool { presentation == .embeddedInBattleTracker }
    private var panelSpacing: CGFloat { isEmbedded ? DesignTokens.Spacing.md : DesignTokens.Spacing.lg }

    var body: some View {
        VStack(alignment: .leading, spacing: panelSpacing) {
            if presentation == .standalone {
                introSection
            }
            if isEmbedded {
                embeddedContextBar
            }
            matchupPanels
            attackProfileBar
            if isEmbedded {
                diceSection
                resultsSection
            } else {
                resultsSection
                diceSection
            }
            optionsSection
            simulatedActionsSection
            multiAttackSection
            if presentation == .standalone {
                referenceLinksSection
            }
        }
    }

    @ViewBuilder
    private var embeddedContextBar: some View {
        if let attackerPlayerName, let defenderPlayerName {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Label(attackerPlayerName, systemImage: "scope")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Image(systemName: "arrow.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Label(defenderPlayerName, systemImage: "shield.fill")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .foregroundStyle(.secondary)
            .padding(DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                String(localized: "\(attackerPlayerName) attacks \(defenderPlayerName)")
            )
        }
    }

    private var introSection: some View {
        IntroCallout(
            text: isSimulated
                ? "Pick attacker and defender, enter your dice or tap Roll Attack, and see hit, save, ward, and damage instantly."
                : "Pick attacker and defender, enter the dice you rolled at the table, and the result updates automatically.",
            systemImage: "arrow.left.arrow.right"
        )
    }

    @ViewBuilder
    private var matchupPanels: some View {
        if isEmbedded {
            embeddedMatchupCard
        } else if horizontalSizeClass == .regular {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                attackerPanel
                MatchupVersusBadge()
                defenderPanel
            }
        } else {
            attackerPanel
            MatchupVersusBadge()
            defenderPanel
        }
    }

    private var embeddedMatchupCard: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    attackerPanel
                    MatchupVersusBadge()
                    defenderPanel
                }
            } else {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    attackerPanel
                    MatchupVersusBadge()
                    defenderPanel
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var attackerPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Attacker"),
            systemImage: "scope",
            armyName: viewModel.selectedAttackerArmy?.name ?? "",
            armies: viewModel.armies,
            armyId: $viewModel.attackerArmyId,
            units: viewModel.selectedAttackerArmy?.units ?? [],
            unitId: $viewModel.attackerUnitId,
            weapons: viewModel.evaluableWeapons,
            weaponId: $viewModel.attackerWeaponId,
            showsWeaponPicker: true,
            showsArmyPicker: !locksArmies,
            usesCompactStyle: isEmbedded,
            onArmyChange: viewModel.setAttackerArmy,
            onUnitChange: viewModel.setAttackerUnit,
            onWeaponChange: viewModel.setAttackerWeapon
        )
        .accessibilityIdentifier("\(accessibilityPrefix).attackerPanel")
    }

    private var defenderPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Defender"),
            systemImage: "shield.fill",
            armyName: viewModel.selectedDefenderArmy?.name ?? "",
            armies: opposingArmies(forAttackerId: viewModel.attackerArmyId),
            armyId: $viewModel.defenderArmyId,
            units: viewModel.selectedDefenderArmy?.units ?? [],
            unitId: $viewModel.defenderUnitId,
            weaponId: .constant(""),
            showsArmyPicker: !locksArmies,
            usesCompactStyle: isEmbedded,
            onArmyChange: viewModel.setDefenderArmy,
            onUnitChange: viewModel.setDefenderUnit,
            onWeaponChange: { _ in }
        )
        .accessibilityIdentifier("\(accessibilityPrefix).defenderPanel")
    }

    @ViewBuilder
    private var attackProfileBar: some View {
        if let weapon = viewModel.selectedAttackerWeapon,
           let defender = viewModel.selectedDefenderUnit,
           let save = defender.save {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "target")
                    .foregroundStyle(.secondary)
                Text(
                    "\(weapon.name): Hit \(weapon.hit)+ · Wound \(weapon.wound)+ · Rend \(weapon.rend) · Dmg \(viewModel.damage)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                Spacer()
                Text(String(localized: "Save \(save)+"))
                    .font(.caption.weight(.semibold))
            }
            .padding(DesignTokens.Spacing.sm)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            .onAppear { onSyncMultiAttack() }
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if let evaluation = viewModel.evaluation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                CombatOutcomeBanner(
                    evaluation: evaluation,
                    matchupTitle: viewModel.matchupTitle,
                    accessibilityId: "\(accessibilityPrefix).outcomeBanner"
                )
                DisclosureGroup(String(localized: "Step-by-step breakdown")) {
                    ForEach(evaluation.steps) { step in
                        RollStepCard(step: step)
                    }
                }
                .font(.subheadline.weight(.semibold))
            }
            .accessibilityIdentifier("\(accessibilityPrefix).results")
        } else if !viewModel.canEvaluate {
            Text(String(localized: "Choose both units and a weapon to resolve attacks."))
                .font(.callout)
                .foregroundStyle(.secondary)
                .modifier(ConditionalResolverCard(enabled: !isEmbedded))
        }
    }

    private var diceSection: some View {
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

    @ViewBuilder
    private var optionsSection: some View {
        DisclosureGroup(isExpanded: $showsAdvancedOptions) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                DiceInputModePicker(mode: Binding(
                    get: { diceInputMode },
                    set: { diceInputMode = $0 }
                ))

                if !viewModel.matchupBuffs.isEmpty {
                    if !viewModel.attackerBuffs.isEmpty {
                        buffGroup(title: String(localized: "Attacker"), buffs: viewModel.attackerBuffs)
                    }
                    if !viewModel.defenderBuffs.isEmpty {
                        buffGroup(title: String(localized: "Defender"), buffs: viewModel.defenderBuffs)
                    }
                }

                Toggle(isOn: Binding(
                    get: { viewModel.rollOptions.mortalDamage },
                    set: {
                        viewModel.rollOptions.mortalDamage = $0
                        viewModel.refreshEvaluation()
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Mortal damage"))
                            .font(.subheadline.weight(.semibold))
                        Text(String(localized: "Skip the save roll — damage applies on a successful wound."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .accessibilityIdentifier("\(accessibilityPrefix).mortalDamage")
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            if isEmbedded {
                Text(String(localized: "Abilities & Options"))
                    .font(.subheadline.weight(.semibold))
            } else {
                SectionHeader(title: String(localized: "Abilities & Options"), systemImage: "sparkles")
            }
        }
        .modifier(ConditionalResolverCard(enabled: !isEmbedded))
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
    private var simulatedActionsSection: some View {
        if isSimulated {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SimulatedDiceHint()
                SimulatedRollSummaryView(rolls: viewModel.lastRolls)
                PrimaryButton(
                    title: String(localized: "Roll Attack"),
                    accessibilityId: "\(accessibilityPrefix).roll.attack"
                ) {
                    viewModel.rollAttack()
                }
            }
            .surfaceCard()
        }
    }

    @ViewBuilder
    private var multiAttackSection: some View {
        if viewModel.selectedAttackerWeapon != nil, viewModel.selectedDefenderUnit?.save != nil {
            DisclosureGroup(isExpanded: $showsMultiAttack) {
                MultiAttackEvaluatorView(
                    viewModel: multiAttackViewModel,
                    weaponName: viewModel.selectedAttackerWeapon?.name ?? "",
                    ruleSections: ruleSections,
                    isSimulated: isSimulated
                )
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                if isEmbedded {
                    Text(String(localized: "Multiple Attacks"))
                        .font(.subheadline.weight(.semibold))
                } else {
                    SectionHeader(title: String(localized: "Multiple Attacks"), systemImage: "repeat")
                }
            }
            .modifier(ConditionalResolverCard(enabled: !isEmbedded))
        }
    }

    @ViewBuilder
    private var referenceLinksSection: some View {
        ReferenceLinksGroup {
            if let combatSection = ruleSections.first(where: { $0.id == "combat-sequence" }) {
                NavigationLink {
                    RuleSectionDetailView(section: combatSection, allSections: ruleSections)
                } label: {
                    ReferenceLinkRow(title: combatSection.title, systemImage: "doc.text")
                }
                .accessibilityIdentifier("\(accessibilityPrefix).relatedRule")
                Divider().padding(.leading, DesignTokens.Spacing.md)
            }
            NavigationLink {
                RulesGlossaryView()
            } label: {
                ReferenceLinkRow(title: String(localized: "Rules Glossary"), systemImage: "book.fill")
            }
            .accessibilityIdentifier("\(accessibilityPrefix).glossary")
        }
    }

    private var accessibilityPrefix: String {
        presentation == .embeddedInBattleTracker ? "battleTracker.combatResolver" : "matchup"
    }

    private func opposingArmies(forAttackerId attackerId: String) -> [SpearheadArmy] {
        viewModel.armies.filter { $0.id != attackerId }
    }
}

private struct ConditionalResolverCard: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.surfaceCard()
        } else {
            content
        }
    }
}
