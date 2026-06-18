import SwiftUI
import TabletomeDomain

struct CombatResolverPanel: View {
    enum Presentation {
        case standalone
        case embeddedInBattleTracker
    }

    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedSingleAttack: Bool

    let ruleSections: [RuleSection]
    let presentation: Presentation
    var attackerPlayerName: String?
    var defenderPlayerName: String?
    var defenderWoundsRemaining: Int?
    var unitWoundsRemaining: [String: Int] = [:]
    let onSyncMultiAttack: () -> Void
    var onApplyDamage: ((Int) -> Void)?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsCombatSequencePrimer = false

    private var diceInputMode: DiceInputMode {
        get { DiceInputMode(rawValue: diceInputModeRaw) ?? .physical }
        nonmutating set { diceInputModeRaw = newValue.rawValue }
    }

    private var isSimulated: Bool { diceInputMode == .simulated }
    private var locksArmies: Bool { presentation == .embeddedInBattleTracker }
    private var isEmbedded: Bool { presentation == .embeddedInBattleTracker }
    private var panelSpacing: CGFloat { isEmbedded ? DesignTokens.Spacing.md : DesignTokens.Spacing.lg }

    private var usesSideBySideMatchup: Bool {
        TabletomeLayout.usesSideBySideLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass,
            isAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: panelSpacing) {
            if presentation == .standalone {
                introSection
            }
            if isEmbedded {
                embeddedContextBar
                combatSequencePrimerSection
            }
            matchupPanels
            attackProfileBar
            deployedModelSection
            hitDiceBannerSection
            if !isSimulated {
                batchCombatSection
            }
            if isEmbedded {
                advancedSingleAttackSection
            } else {
                resultsSection
                diceSection
                optionsSection
                simulatedActionsSection
                multiAttackSection
            }
            if presentation == .standalone {
                referenceLinksSection
            }
        }
        .onChange(of: viewModel.attackerUnitId) { _, _ in
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.attackerDeployedModelCount) { _, _ in
            viewModel.clearVariableAttackResolution()
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.resolvedVariableAttackCount) { _, _ in
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.defenderUnitId) { _, _ in
            guard isEmbedded else { return }
            viewModel.applySuggestedDefenderWards()
            if viewModel.hasSuggestedWardBuffs {
                showsAdvancedOptions = true
            }
            onSyncMultiAttack()
            syncBatchCombat()
        }
        .onChange(of: viewModel.attackerWeaponId) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.enabledBuffIds) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.damage) { _, _ in
            syncBatchCombat()
        }
        .onChange(of: viewModel.rollOptions) { _, _ in
            syncBatchCombat()
        }
        .onAppear {
            guard isEmbedded else { return }
            showsCombatSequencePrimer = false
            syncBatchCombat()
        }
    }

    private func syncBatchCombat() {
        batchViewModel.sync(from: viewModel)
    }

    @ViewBuilder
    private var batchCombatSection: some View {
        BatchCombatResolverSection(
            batchViewModel: batchViewModel,
            combatViewModel: viewModel,
            accessibilityPrefix: accessibilityPrefix,
            defenderName: viewModel.selectedDefenderUnit?.name,
            defenderWoundsRemaining: defenderWoundsRemaining,
            onApplyDamage: onApplyDamage
        )
    }

    @ViewBuilder
    private var advancedSingleAttackSection: some View {
        DisclosureGroup(isExpanded: $showsAdvancedSingleAttack) {
            VStack(alignment: .leading, spacing: panelSpacing) {
                diceSection
                resultsSection
                simulatedActionsSection
                multiAttackSection
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Text(String(localized: "Single attack & coaching"))
                .font(.subheadline.weight(.semibold))
        }
        optionsSection
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

    @ViewBuilder
    private var combatSequencePrimerSection: some View {
        CombatSequencePrimer(
            isExpanded: $showsCombatSequencePrimer,
            showsDismissButton: !NewPlayerTipsStore.hasDismissedCombatSequencePrimer,
            onDismiss: {
                NewPlayerTipsStore.dismissCombatSequencePrimer()
            }
        )
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
        } else if usesSideBySideMatchup {
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
            if usesSideBySideMatchup {
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
            woundsRemaining: attackerWoundsRemaining,
            unitWoundsRemaining: unitWoundsLookup(for: viewModel.attackerArmyId),
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
            woundsRemaining: defenderWoundsRemaining,
            unitWoundsRemaining: unitWoundsLookup(for: viewModel.defenderArmyId),
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
    private var deployedModelSection: some View {
        if viewModel.selectedAttackerUnit != nil, viewModel.selectedAttackerWeapon != nil {
            DeployedModelCountStepper(
                modelCount: $viewModel.attackerDeployedModelCount,
                warscrollModelCount: viewModel.selectedAttackerUnit?.modelCount,
                usesVariableAttacks: viewModel.attackerUsesVariableAttacks,
                onChange: onSyncMultiAttack,
                accessibilityPrefix: accessibilityPrefix
            )
        }
    }

    @ViewBuilder
    private var hitDiceBannerSection: some View {
        if viewModel.selectedAttackerWeapon?.hasCritAutoWound == true {
            CritAutoWoundCoachingHint()
        }
        if viewModel.attackerUsesVariableAttacks {
            VariableAttacksRollCard(
                expression: viewModel.selectedAttackerWeapon?.attacks ?? "D6",
                modelCount: viewModel.attackerDeployedModelCount,
                perModelTotals: viewModel.variableAttackPerModelTotals,
                resolvedAttackCount: $viewModel.resolvedVariableAttackCount,
                breakdown: viewModel.variableAttackRollBreakdown,
                onRollAll: {
                    viewModel.rollVariableAttacks()
                    onSyncMultiAttack()
                },
                onRollNextModel: {
                    viewModel.rollVariableAttacksForNextModel()
                    onSyncMultiAttack()
                },
                accessibilityPrefix: accessibilityPrefix
            )
        }
        if let plan = viewModel.attackerHitDicePlan {
            CombatRollCountBanner(
                plan: plan,
                accessibilityPrefix: accessibilityPrefix
            )
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        CombatResolverResultsSection(
            viewModel: viewModel,
            isEmbedded: isEmbedded,
            accessibilityPrefix: accessibilityPrefix,
            defenderWoundsRemaining: defenderWoundsRemaining,
            onApplyDamage: onApplyDamage
        )
    }

    private var diceSection: some View {
        CombatResolverDiceSection(
            viewModel: viewModel,
            isEmbedded: isEmbedded,
            isSimulated: isSimulated,
            accessibilityPrefix: accessibilityPrefix
        )
    }

    private var optionsSection: some View {
        CombatResolverOptionsSection(
            viewModel: viewModel,
            showsAdvancedOptions: $showsAdvancedOptions,
            diceInputModeRaw: $diceInputModeRaw,
            isEmbedded: isEmbedded,
            accessibilityPrefix: accessibilityPrefix
        )
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
        CombatResolverMultiAttackSection(
            viewModel: viewModel,
            multiAttackViewModel: multiAttackViewModel,
            showsMultiAttack: $showsMultiAttack,
            ruleSections: ruleSections,
            isEmbedded: isEmbedded,
            isSimulated: isSimulated
        )
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
                ReferenceLinkRow(
                    title: GameSystemRulesLabels.glossaryTitle(gameSystemId: GameSystemRulesLabels.defaultGameSystemId),
                    systemImage: "book.fill"
                )
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

    private var attackerWoundsRemaining: Int? {
        guard !viewModel.attackerArmyId.isEmpty, !viewModel.attackerUnitId.isEmpty else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: viewModel.attackerArmyId, unitId: viewModel.attackerUnitId)
        return unitWoundsRemaining[key]
    }

    private func unitWoundsLookup(for armyId: String) -> ((String) -> Int?)? {
        guard !armyId.isEmpty, !unitWoundsRemaining.isEmpty else { return nil }
        return { unitId in
            unitWoundsRemaining[UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)]
        }
    }
}

struct ConditionalResolverCard: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.surfaceCard()
        } else {
            content
        }
    }
}
