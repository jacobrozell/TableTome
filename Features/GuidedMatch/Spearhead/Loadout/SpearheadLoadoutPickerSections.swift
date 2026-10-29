import SwiftUI
import TabletomeDomain

// MARK: - Player Toggle

struct SpearheadLoadoutPlayerToggle: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    @Binding var currentPlayerIsOne: Bool
    let playerOneComplete: Bool
    let playerTwoComplete: Bool

    var body: some View {
        Picker("Player", selection: $currentPlayerIsOne) {
            Text(playerPickerLabel(
                name: viewModel.matchState.playerOne.playerName,
                isComplete: playerOneComplete
            ))
            .tag(true)

            Text(playerPickerLabel(
                name: viewModel.matchState.playerTwo.playerName,
                isComplete: playerTwoComplete
            ))
            .tag(false)
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("loadout.playerPicker")
    }

    private func playerPickerLabel(name: String, isComplete: Bool) -> String {
        let displayName = name.isEmpty
            ? String(localized: "Player")
            : name
        return isComplete ? "\(displayName) ✓" : displayName
    }
}

// MARK: - Progress Badges

struct SpearheadLoadoutProgressIndicator: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let currentPlayerIsOne: Bool

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            progressBadge(
                title: String(localized: "Regiment"),
                isComplete: currentPlayerIsOne
                    ? viewModel.matchState.playerOne.regimentAbilityId != nil
                    : viewModel.matchState.playerTwo.regimentAbilityId != nil
            )
            progressBadge(
                title: String(localized: "Enhancement"),
                isComplete: currentPlayerIsOne
                    ? viewModel.matchState.playerOne.enhancementId != nil
                    : viewModel.matchState.playerTwo.enhancementId != nil
            )
        }
    }

    @ViewBuilder
    private func progressBadge(title: String, isComplete: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? .green : .secondary)
            Text(title)
                .font(.caption)
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, 4)
        .background(TTColor.sunken, in: Capsule())
    }
}

// MARK: - Regiment Picker

struct SpearheadLoadoutRegimentPicker: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let currentPlayerIsOne: Bool

    private var currentPlayer: PlayerArmySelection {
        currentPlayerIsOne ? viewModel.matchState.playerOne : viewModel.matchState.playerTwo
    }

    private var currentArmy: SpearheadArmy? {
        viewModel.army(factionId: currentPlayer.factionId, armyId: currentPlayer.armyId)
    }

    var body: some View {
        if let army = currentArmy {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                loadoutSectionHeader(
                    title: String(localized: "Regiment Ability"),
                    subtitle: String(localized: "Affects your entire army"),
                    icon: "flag.fill"
                )

                let selectedId = currentPlayerIsOne
                    ? viewModel.matchState.playerOne.regimentAbilityId
                    : viewModel.matchState.playerTwo.regimentAbilityId

                ForEach(army.regimentAbilities) { option in
                    LoadoutOptionCard(
                        option: option,
                        isSelected: selectedId == option.id,
                        gameSystemId: viewModel.gameSystemId.rawValue,
                        ruleSections: ruleSections
                    ) {
                        viewModel.setRegimentAbility(playerIsOne: currentPlayerIsOne, abilityId: option.id)
                    }
                }
            }
        } else {
            Text(String(localized: "Select an army first"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .surfaceCard()
        }
    }
}

// MARK: - Enhancement Picker

struct SpearheadLoadoutEnhancementPicker: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let currentPlayerIsOne: Bool

    private var currentPlayer: PlayerArmySelection {
        currentPlayerIsOne ? viewModel.matchState.playerOne : viewModel.matchState.playerTwo
    }

    private var currentArmy: SpearheadArmy? {
        viewModel.army(factionId: currentPlayer.factionId, armyId: currentPlayer.armyId)
    }

    var body: some View {
        if let army = currentArmy {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                loadoutSectionHeader(
                    title: String(localized: "Enhancement"),
                    subtitle: String(localized: "For your general only"),
                    icon: "sparkles"
                )

                let selectedId = currentPlayerIsOne
                    ? viewModel.matchState.playerOne.enhancementId
                    : viewModel.matchState.playerTwo.enhancementId

                ForEach(army.enhancements) { option in
                    LoadoutOptionCard(
                        option: option,
                        isSelected: selectedId == option.id,
                        gameSystemId: viewModel.gameSystemId.rawValue,
                        ruleSections: ruleSections
                    ) {
                        viewModel.setEnhancement(playerIsOne: currentPlayerIsOne, enhancementId: option.id)
                    }
                }
            }
        } else {
            Text(String(localized: "Select an army first"))
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .surfaceCard()
        }
    }
}

// MARK: - Shared Header

@ViewBuilder
func loadoutSectionHeader(title: String, subtitle: String, icon: String) -> some View {
    HStack(spacing: DesignTokens.Spacing.sm) {
        Image(systemName: icon)
            .foregroundStyle(Color.accentColor)
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
