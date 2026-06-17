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
    var defenderWoundsRemaining: Int?
    let onSyncMultiAttack: () -> Void
    var onApplyDamage: ((Int) -> Void)?

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
        .onChange(of: viewModel.defenderUnitId) { _, _ in
            guard isEmbedded else { return }
            viewModel.applySuggestedDefenderWards()
            if viewModel.hasSuggestedWardBuffs {
                showsAdvancedOptions = true
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
