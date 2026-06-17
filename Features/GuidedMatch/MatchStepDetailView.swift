import SwiftUI
import TabletomeDomain

struct MatchStepDetailView: View {
    let step: MatchSetupStep
    let stepNumber: Int
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isComplete: Bool {
        viewModel.matchState.completedStepIds.contains(step.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: step.body)

                stepSpecificContent

                if let relatedSection {
                    ReferenceLinksGroup {
                        NavigationLink {
                            RuleSectionDetailView(section: relatedSection, allSections: ruleSections)
                        } label: {
                            ReferenceLinkRow(title: relatedSection.title, systemImage: "doc.text")
                        }
                        .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                        .accessibilityIdentifier("guidedMatch.relatedRule.\(step.id)")
                    }
                }

                if !step.tips.isEmpty {
                    TipsCard(tips: step.tips)
                }

                stepCompletionStatus
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.syncAutoCompletions()
        }
    }

    @ViewBuilder
    private var stepCompletionStatus: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? .green : .secondary)
            Text(
                isComplete
                    ? String(localized: "Step complete")
                    : String(localized: "Complete the actions above — this step checks off automatically.")
            )
            .font(.subheadline)
            .foregroundStyle(isComplete ? .primary : .secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
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
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteDeploymentStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                onToggle: viewModel.setDeploymentStep
            )
            ReferenceLinksGroup {
                NavigationLink {
                    BattleTacticsReferenceView(ruleSections: ruleSections)
                } label: {
                    ReferenceLinkRow(
                        title: String(localized: "Battle Tactics & Twists"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }

    private var battleStartLinks: some View {
        ReferenceLinksGroup {
            NavigationLink {
                BattleTacticsReferenceView(ruleSections: ruleSections)
            } label: {
                ReferenceLinkRow(
                    title: String(localized: "Battle Tactics & Twists"),
                    systemImage: "rectangle.stack"
                )
            }
        }
    }

    private var matchupCard: some View {
        Group {
            if viewModel.matchState.hasBothArmies, let summary = viewModel.matchupSummary {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    SectionHeader(title: String(localized: "Selected Matchup"), systemImage: "person.2.fill")
                    Text(summary)
                        .font(.subheadline.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .surfaceCard()
            }
        }
    }

    private var attackerPicker: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Who is the attacker?"), systemImage: "flag.fill")

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
        .surfaceCard()
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
            SectionHeader(title: String(localized: "Loadout Summary"), systemImage: "tray.full")

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
            SectionHeader(title: title, systemImage: "list.bullet")

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
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
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
        .surfaceCard()
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
