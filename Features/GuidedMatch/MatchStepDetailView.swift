import SwiftUI
import TabletomeDomain

struct MatchStepDetailView: View {
    let step: MatchSetupStep
    let stepNumber: Int
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    @State private var isComplete = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                stepSpecificContent

                if let relatedSection {
                    NavigationLink {
                        RuleSectionDetailView(section: relatedSection, allSections: ruleSections)
                    } label: {
                        Label(relatedSection.title, systemImage: "doc.text")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                    .accessibilityIdentifier("guidedMatch.relatedRule.\(step.id)")
                }

                if !step.tips.isEmpty {
                    tipsSection
                }

                Toggle(isOn: $isComplete) {
                    Text(String(localized: "Mark step complete"))
                        .font(.headline)
                }
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
                .onChange(of: isComplete) { _, newValue in
                    viewModel.setStepComplete(step.id, complete: newValue)
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isComplete = viewModel.matchState.completedStepIds.contains(step.id)
        }
    }

    @ViewBuilder
    private var stepSpecificContent: some View {
        switch step.id {
        case "choose-armies":
            matchupCard
        case "roll-attacker":
            attackerPicker
        case "regiment-abilities":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                armyOptionsSection(
                    title: String(localized: "Regiment Abilities"),
                    playerOneKeyPath: \.regimentAbilityId,
                    playerTwoKeyPath: \.regimentAbilityId,
                    options: { army in army.regimentAbilities },
                    onSelect: viewModel.setRegimentAbility
                )
                loadoutSummarySection(showRegiment: true, showEnhancement: false)
            }
        case "enhancements":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                armyOptionsSection(
                    title: String(localized: "Enhancements"),
                    playerOneKeyPath: \.enhancementId,
                    playerTwoKeyPath: \.enhancementId,
                    options: { army in army.enhancements },
                    onSelect: viewModel.setEnhancement
                )
                loadoutSummarySection(showRegiment: true, showEnhancement: true)
            }
        case "realm-battlefield":
            deploymentSetupSection
        case "fight-battle":
            battleStartLinks
        default:
            EmptyView()
        }
    }

    private var deploymentSetupSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            DeploymentChecklistCard(
                completedSteps: BattleTrackerStore.load().completedDeploymentSteps,
                onToggle: { step, complete in
                    var state = BattleTrackerStore.load()
                    if complete {
                        state.completedDeploymentSteps.insert(step.rawValue)
                    } else {
                        state.completedDeploymentSteps.remove(step.rawValue)
                    }
                    BattleTrackerStore.save(state)
                }
            )
            NavigationLink {
                BattleTacticsReferenceView(ruleSections: ruleSections)
            } label: {
                Label(String(localized: "Battle Tactics & Twists"), systemImage: "rectangle.stack")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
        }
    }

    private var battleStartLinks: some View {
        NavigationLink {
            BattleTacticsReferenceView(ruleSections: ruleSections)
        } label: {
            Label(String(localized: "Battle Tactics & Twists"), systemImage: "rectangle.stack")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: DesignTokens.minTouchTarget)
        }
    }

    private var matchupCard: some View {
        Group {
            if viewModel.matchState.hasBothArmies, let summary = viewModel.matchupSummary {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(String(localized: "Selected Matchup"))
                        .font(.headline)
                    Text(summary)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignTokens.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            }
        }
    }

    private var attackerPicker: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Who is the attacker?"))
                .font(.headline)

            Picker(String(localized: "Attacker"), selection: attackerBinding) {
                Text(String(localized: "Not decided")).tag(Optional<Bool>.none)
                Text(viewModel.matchState.playerOne.playerName).tag(Optional(true))
                Text(viewModel.matchState.playerTwo.playerName).tag(Optional(false))
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("guidedMatch.attackerPicker")

            if let isPlayerOne = viewModel.matchState.attackerIsPlayerOne {
                let attacker = isPlayerOne ? viewModel.matchState.playerOne : viewModel.matchState.playerTwo
                let defender = isPlayerOne ? viewModel.matchState.playerTwo : viewModel.matchState.playerOne
                Text(
                    String(
                        localized: "\(attacker.playerName) attacks. \(defender.playerName) defends and chooses the realm side."
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var attackerBinding: Binding<Bool?> {
        Binding(
            get: { viewModel.matchState.attackerIsPlayerOne },
            set: { newValue in
                if let isPlayerOne = newValue {
                    viewModel.setAttacker(isPlayerOne: isPlayerOne)
                }
            }
        )
    }

    private func loadoutSummarySection(showRegiment: Bool, showEnhancement: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Loadout Summary"))
                .font(.headline)

            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerLoadoutCard(
                        player: viewModel.matchState.playerOne,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement
                    )
                    playerLoadoutCard(
                        player: viewModel.matchState.playerTwo,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement
                    )
                }
            } else {
                playerLoadoutCard(
                    player: viewModel.matchState.playerOne,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement
                )
                playerLoadoutCard(
                    player: viewModel.matchState.playerTwo,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement
                )
            }
        }
    }

    private func playerLoadoutCard(
        player: PlayerArmySelection,
        isAttacker: Bool,
        showRegiment: Bool,
        showEnhancement: Bool
    ) -> some View {
        LoadoutSummaryCard(
            playerName: player.playerName,
            armyName: viewModel.armyName(for: player) ?? String(localized: "No army selected"),
            regimentAbility: showRegiment ? viewModel.regimentAbility(for: player) : nil,
            enhancement: showEnhancement ? viewModel.enhancement(for: player) : nil,
            isAttacker: isAttacker
        )
    }

    private func armyOptionsSection(
        title: String,
        playerOneKeyPath: KeyPath<PlayerArmySelection, String?>,
        playerTwoKeyPath: KeyPath<PlayerArmySelection, String?>,
        options: (SpearheadArmy) -> [ArmyRuleOption],
        onSelect: @escaping (Bool, String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text(title)
                .font(.title3.bold())

            if horizontalSizeClass == .regular {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerOptionPicker(
                        player: viewModel.matchState.playerOne,
                        selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        playerIsOne: true,
                        options: options,
                        onSelect: onSelect
                    )
                    playerOptionPicker(
                        player: viewModel.matchState.playerTwo,
                        selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        playerIsOne: false,
                        options: options,
                        onSelect: onSelect
                    )
                }
            } else {
                playerOptionPicker(
                    player: viewModel.matchState.playerOne,
                    selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    playerIsOne: true,
                    options: options,
                    onSelect: onSelect
                )

                playerOptionPicker(
                    player: viewModel.matchState.playerTwo,
                    selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    playerIsOne: false,
                    options: options,
                    onSelect: onSelect
                )
            }
        }
    }

    private func playerOptionPicker(
        player: PlayerArmySelection,
        selectedId: String?,
        isAttacker: Bool,
        playerIsOne: Bool,
        options: (SpearheadArmy) -> [ArmyRuleOption],
        onSelect: @escaping (Bool, String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text(player.playerName)
                    .font(.headline)
                if isAttacker {
                    Text(String(localized: "Attacker — picks first"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let army = viewModel.army(factionId: player.factionId, armyId: player.armyId) {
                let armyOptions = options(army)
                if armyOptions.isEmpty {
                    Text(String(localized: "See your faction's free Spearhead download for regiment and enhancement options."))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(armyOptions) { option in
                        Button {
                            onSelect(playerIsOne, option.id)
                        } label: {
                            ArmyRuleOptionCard(
                                option: option,
                                isSelected: selectedId == option.id
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedId == option.id ? .isSelected : [])
                        .accessibilityIdentifier("guidedMatch.option.\(option.id)")
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Tips"))
                .font(.headline)
            ForEach(step.tips, id: \.self) { tip in
                Label(tip, systemImage: "lightbulb")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
