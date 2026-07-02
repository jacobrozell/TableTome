import SwiftUI
import TabletomeDomain

/// Shared setup-step building blocks for Guided Match (Spearhead steps + legacy detail).
@MainActor
struct GuidedMatchStepParts {
    let viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    @ViewBuilder
    func recommendedDefaultsControls() -> some View {
        if viewModel.matchState.hasBothArmies {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Button(String(localized: "Use recommended defaults")) {
                    viewModel.applyRecommendedLoadouts()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.applyRecommendedDefaults")

                Text(
                    String(
                        localized: "Fills enhancement and objective picks recommended for newcomers."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    func regimentAbilityCoachingCallout() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(
                String(localized: "What is a regiment ability?"),
                systemImage: "questionmark.circle"
            )
            .font(.subheadline.weight(.semibold))

            Text(
                String(
                    localized: """
                    This is not a unit group on the table. Each Spearhead army sheet lists two regiment abilities — \
                    pick one pre-battle rule for your whole army before deployment.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.regimentCoaching")
    }

    @ViewBuilder
    func enhancementCoachingCallout() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Enhancement for your general"), systemImage: "sparkles")
                .font(.subheadline.weight(.semibold))

            Text(
                String(
                    localized: """
                    Each army has four enhancement cards — pick one for your general only. \
                    Protect them; losing your general hurts more when they carry this upgrade.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.enhancementCoaching")
    }

    @ViewBuilder
    func spearheadBattleTacticsSection() -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(
                String(
                    localized: """
                    Each player shuffles the battle tactic deck from their own army box — not the shared twist deck \
                    from the battlefield pack.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Battle Tactics & Twists"),
                        systemImage: "rectangle.stack"
                    )
                }
                .accessibilityIdentifier("guidedMatch.enhancements.battleTactics")
            }
        }
    }

    @ViewBuilder
    func loadoutSummarySection(
        showRegiment: Bool,
        showEnhancement: Bool,
        showSecondary: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Loadout Summary"), systemImage: "tray.full")

            if usesSideBySideColumns {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerLoadoutCard(
                        player: viewModel.matchState.playerOne,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement,
                        showSecondary: showSecondary
                    )
                    playerLoadoutCard(
                        player: viewModel.matchState.playerTwo,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement,
                        showSecondary: showSecondary
                    )
                }
            } else {
                playerLoadoutCard(
                    player: viewModel.matchState.playerOne,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement,
                    showSecondary: showSecondary
                )
                playerLoadoutCard(
                    player: viewModel.matchState.playerTwo,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement,
                    showSecondary: showSecondary
                )
            }
        }
    }

    @ViewBuilder
    func armyOptionsSection(
        title: String,
        playerOneKeyPath: KeyPath<PlayerArmySelection, String?>,
        playerTwoKeyPath: KeyPath<PlayerArmySelection, String?>,
        options: (SpearheadArmy) -> [ArmyRuleOption],
        onSelect: @escaping (Bool, String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: title, systemImage: "list.bullet")

            if usesSideBySideColumns {
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

    @ViewBuilder
    private func playerLoadoutCard(
        player: PlayerArmySelection,
        isAttacker: Bool,
        showRegiment: Bool,
        showEnhancement: Bool,
        showSecondary: Bool
    ) -> some View {
        LoadoutSummaryCard(
            playerName: player.playerName,
            armyName: viewModel.armyName(for: player) ?? String(localized: "No army selected"),
            regimentAbility: showRegiment ? viewModel.regimentAbility(for: player) : nil,
            enhancement: showEnhancement ? viewModel.enhancement(for: player) : nil,
            secondaryObjective: showSecondary ? viewModel.secondaryObjective(for: player) : nil,
            battleTacticDeckName: viewModel.battleTacticDeckName(for: player),
            isAttacker: isAttacker
        )
    }

    @ViewBuilder
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
                    Text(
                        String(
                            localized: "See your faction's free Spearhead download for regiment and enhancement options."
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                } else {
                    ForEach(armyOptions) { option in
                        Button {
                            onSelect(playerIsOne, option.id)
                        } label: {
                            ArmyRuleOptionCard(
                                option: option,
                                isSelected: selectedId == option.id,
                                gameSystemId: viewModel.gameSystemId.rawValue,
                                ruleSections: ruleSections
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
}
