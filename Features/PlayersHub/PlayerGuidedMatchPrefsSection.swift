import SwiftUI
import TabletomeDomain

struct PlayerGuidedMatchPrefsSection: View {
    @ObservedObject var viewModel: PlayerDetailViewModel
    @State private var showsLoadoutDefaults = false
    @State private var showsPreferredArmies = false

    var body: some View {
        if let profile = viewModel.profile {
            Section {
                Picker(
                    String(localized: "Experience"),
                    selection: Binding(
                        get: { profile.guidedMatchPreferences.experienceLevel },
                        set: { level in Task { await viewModel.setExperienceLevel(level) } }
                    )
                ) {
                    Text(String(localized: "Beginner")).tag(PlayerExperienceLevel.beginner)
                    Text(String(localized: "Table regular")).tag(PlayerExperienceLevel.tableRegular)
                }
                .accessibilityIdentifier("playersHub.prefs.experience")

                Picker(
                    String(localized: "Default dice"),
                    selection: Binding(
                        get: { dicePreferenceTag(profile.guidedMatchPreferences.defaultDiceInputMode) },
                        set: { tag in Task { await viewModel.setDefaultDiceInputMode(tag.diceModeRawValue) } }
                    )
                ) {
                    Text(String(localized: "Device default")).tag(DicePreferenceTag.deviceDefault)
                    Text(String(localized: "Physical dice")).tag(DicePreferenceTag.physical)
                    Text(String(localized: "Roll in app")).tag(DicePreferenceTag.simulated)
                }
                .accessibilityIdentifier("playersHub.prefs.diceMode")
            } header: {
                Text(String(localized: "Guided Match"))
            } footer: {
                Text(
                    String(
                        localized: """
                        Table regular players see fewer coaching tips. Dice preference applies when this player is active in battle.
                        """
                    )
                )
            }

            if !viewModel.ownedArmyIds().isEmpty, let catalog = viewModel.catalog {
                Section {
                    DisclosureGroup(
                        String(localized: "Default loadouts"),
                        isExpanded: $showsLoadoutDefaults
                    ) {
                        ForEach(loadoutArmies(profile: profile, catalog: catalog), id: \.id) { army in
                            loadoutArmySection(army: army, profile: profile)
                        }
                    }
                } footer: {
                    Text(String(localized: "Pre-fill regiment abilities and enhancements when this player starts a match."))
                }

                if let household = viewModel.household {
                    preferredArmySection(profile: profile, catalog: catalog, household: household)
                }
            }

            Section {
                Button(role: .destructive) {
                    Task { await viewModel.resetCoachingTips() }
                } label: {
                    Label(String(localized: "Reset coaching for this player"), systemImage: "arrow.counterclockwise")
                }
                .accessibilityIdentifier("playersHub.prefs.resetCoaching")
            }
        }
    }

    @ViewBuilder
    private func loadoutArmySection(army: SpearheadArmy, profile: PlayerProfile) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(army.name)
                .font(.subheadline.weight(.semibold))

            if !army.regimentAbilities.isEmpty {
                Picker(
                    String(localized: "Regiment ability"),
                    selection: Binding(
                        get: {
                            profile.guidedMatchPreferences.defaultRegimentAbilityByArmyId[army.id]
                                ?? army.regimentAbilities.first?.id
                                ?? ""
                        },
                        set: { id in Task { await viewModel.setDefaultRegimentAbility(armyId: army.id, abilityId: id) } }
                    )
                ) {
                    ForEach(army.regimentAbilities) { option in
                        Text(option.name).tag(option.id)
                    }
                }
            }

            if !army.enhancements.isEmpty {
                Picker(
                    String(localized: "Enhancement"),
                    selection: Binding(
                        get: {
                            profile.guidedMatchPreferences.defaultEnhancementByArmyId[army.id]
                                ?? army.enhancements.first?.id
                                ?? ""
                        },
                        set: { id in Task { await viewModel.setDefaultEnhancement(armyId: army.id, enhancementId: id) } }
                    )
                ) {
                    ForEach(army.enhancements) { option in
                        Text(option.name).tag(option.id)
                    }
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private func loadoutArmies(profile: PlayerProfile, catalog: SpearheadCatalog) -> [SpearheadArmy] {
        let owned = viewModel.ownedArmyIds()
        return catalog.factions
            .flatMap(\.armies)
            .filter { owned.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    private func dicePreferenceTag(_ raw: String?) -> DicePreferenceTag {
        guard let raw, let mode = DiceInputMode(rawValue: raw) else { return .deviceDefault }
        return mode == .physical ? .physical : .simulated
    }

    @ViewBuilder
    private func preferredArmySection(
        profile: PlayerProfile,
        catalog: SpearheadCatalog,
        household: HouseholdPlayersState
    ) -> some View {
        let opponents = viewModel.opponentArmyOptions(catalog: catalog, household: household)
        let ownedArmies = loadoutArmies(profile: profile, catalog: catalog)
        if !opponents.isEmpty, !ownedArmies.isEmpty {
            Section {
                DisclosureGroup(
                    String(localized: "Rematch shortcuts"),
                    isExpanded: $showsPreferredArmies
                ) {
                    ForEach(opponents, id: \.id) { opponentArmy in
                        Picker(
                            String(localized: "When opponent plays \(opponentArmy.name)"),
                            selection: Binding(
                                get: {
                                    profile.guidedMatchPreferences.preferredArmyIdByOpponentArmyId[opponentArmy.id]
                                        ?? ownedArmies.first?.id
                                        ?? ""
                                },
                                set: { armyId in
                                    Task {
                                        await viewModel.setPreferredArmy(
                                            opponentArmyId: opponentArmy.id,
                                            armyId: armyId
                                        )
                                    }
                                }
                            )
                        ) {
                            ForEach(ownedArmies, id: \.id) { army in
                                Text(army.name).tag(army.id)
                            }
                        }
                    }
                }
            } footer: {
                Text(String(localized: "Suggest your army when this opponent picks theirs in Guided Match. Updated automatically after each game."))
            }
        }
    }
}

private enum DicePreferenceTag: Hashable {
    case deviceDefault
    case physical
    case simulated

    var diceModeRawValue: String? {
        switch self {
        case .deviceDefault: nil
        case .physical: DiceInputMode.physical.rawValue
        case .simulated: DiceInputMode.simulated.rawValue
        }
    }
}
