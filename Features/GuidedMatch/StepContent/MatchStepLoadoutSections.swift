import SwiftUI
import TabletomeDomain

struct MatchStepLoadoutSummarySection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let usesSideBySideColumns: Bool
    let showRegiment: Bool
    let showEnhancement: Bool
    var showSecondary: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Loadout Summary"), systemImage: "tray.full")

            if usesSideBySideColumns {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerLoadoutCard(
                        player: viewModel.matchState.playerOne,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true
                    )
                    playerLoadoutCard(
                        player: viewModel.matchState.playerTwo,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false
                    )
                }
            } else {
                playerLoadoutCard(
                    player: viewModel.matchState.playerOne,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true
                )
                playerLoadoutCard(
                    player: viewModel.matchState.playerTwo,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false
                )
            }
        }
    }

    private func playerLoadoutCard(player: PlayerArmySelection, isAttacker: Bool) -> some View {
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
}

struct MatchStepArmyOptionsSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool
    let title: String
    let playerOneKeyPath: KeyPath<PlayerArmySelection, String?>
    let playerTwoKeyPath: KeyPath<PlayerArmySelection, String?>
    let options: (SpearheadArmy) -> [ArmyRuleOption]
    let onSelect: (Bool, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: title, systemImage: "list.bullet")

            if usesSideBySideColumns {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerOptionPicker(
                        player: viewModel.matchState.playerOne,
                        selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        playerIsOne: true
                    )
                    playerOptionPicker(
                        player: viewModel.matchState.playerTwo,
                        selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        playerIsOne: false
                    )
                }
            } else {
                playerOptionPicker(
                    player: viewModel.matchState.playerOne,
                    selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    playerIsOne: true
                )
                playerOptionPicker(
                    player: viewModel.matchState.playerTwo,
                    selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    playerIsOne: false
                )
            }
        }
    }

    private func playerOptionPicker(
        player: PlayerArmySelection,
        selectedId: String?,
        isAttacker: Bool,
        playerIsOne: Bool
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
                    Text(emptyArmyOptionsMessage)
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

    private var emptyArmyOptionsMessage: String {
        switch viewModel.gameSystemId {
        case .wh40k11e:
            String(localized: "See your Munitorum Field Manual and box datasheets for detachment options.")
        case .wh40k10eCp:
            String(localized: "Choose from the options below — defaults are marked Recommended.")
        case .scTmg:
            String(localized: "Founders Edition armies ship as fixed lists — no extra options to pick.")
        default:
            String(localized: "See your faction's free Spearhead download for regiment and enhancement options.")
        }
    }
}
