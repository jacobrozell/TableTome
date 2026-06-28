import SwiftUI
import TabletomeDomain

struct ArmySelectionView: View {
    let title: String
    let selection: PlayerArmySelection
    let factions: [SpearheadFaction]
    let featuredArmies: GuidedMatchFeaturedArmies
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default
    var dismissesOnSave: Bool = true
    let onSave: (PlayerArmySelection) -> Void

    @State private var playerName: String
    @State private var selectedFactionId: String
    @State private var selectedArmyId: String
    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        selection: PlayerArmySelection,
        factions: [SpearheadFaction],
        featuredArmies: GuidedMatchFeaturedArmies = SpearheadFeaturedArmies.configuration,
        ruleSections: [RuleSection] = [],
        gameSystemId: GameSystemId = .default,
        dismissesOnSave: Bool = true,
        onSave: @escaping (PlayerArmySelection) -> Void
    ) {
        self.title = title
        self.selection = selection
        self.factions = factions
        self.featuredArmies = featuredArmies
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
        self.dismissesOnSave = dismissesOnSave
        self.onSave = onSave
        _playerName = State(initialValue: selection.playerName)
        _selectedFactionId = State(initialValue: selection.factionId)
        _selectedArmyId = State(initialValue: selection.armyId)
    }

    init(
        title: String,
        selection: PlayerArmySelection,
        factions: [SpearheadFaction],
        featuredArmies: GuidedMatchFeaturedArmies = SpearheadFeaturedArmies.configuration,
        ruleSections: [RuleSection] = [],
        gameSystemId: String,
        dismissesOnSave: Bool = true,
        onSave: @escaping (PlayerArmySelection) -> Void
    ) {
        self.init(
            title: title,
            selection: selection,
            factions: factions,
            featuredArmies: featuredArmies,
            ruleSections: ruleSections,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            dismissesOnSave: dismissesOnSave,
            onSave: onSave
        )
    }

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var selectedFaction: SpearheadFaction? {
        factions.first { $0.id == selectedFactionId }
    }

    private var sortedArmies: [SpearheadArmy] {
        selectedFaction?.armies.sorted { lhs, rhs in
            let leftFeatured = featuredArmies.isFeatured(lhs.id)
            let rightFeatured = featuredArmies.isFeatured(rhs.id)
            if leftFeatured != rightFeatured { return leftFeatured && !rightFeatured }
            return lhs.name < rhs.name
        } ?? []
    }

    var body: some View {
        Form {
            Section(String(localized: "Player Name")) {
                TextField(String(localized: "Name"), text: $playerName)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("guidedMatch.playerNameField")
            }

            Section(String(localized: "Faction")) {
                Picker(String(localized: "Faction"), selection: $selectedFactionId) {
                    Text(String(localized: "Select a faction")).tag("")
                    ForEach(factions) { faction in
                        Text(faction.name).tag(faction.id)
                    }
                }
                .pickerStyle(.navigationLink)
                .accessibilityIdentifier("guidedMatch.factionPicker")
                .onChange(of: selectedFactionId) { _, newValue in
                    guard let faction = factions.first(where: { $0.id == newValue }) else {
                        selectedArmyId = ""
                        return
                    }
                    if !faction.armies.contains(where: { $0.id == selectedArmyId }) {
                        selectedArmyId = faction.armies.first?.id ?? ""
                    }
                }
            }

            if let faction = selectedFaction, !sortedArmies.isEmpty {
                Section {
                    ForEach(sortedArmies) { army in
                        Button {
                            selectedArmyId = army.id
                        } label: {
                            ArmyOptionRow(
                                army: army,
                                isSelected: army.id == selectedArmyId,
                                featuredArmies: featuredArmies,
                                gameSystemId: gameSystemId
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(army.id == selectedArmyId ? .isSelected : [])
                        .accessibilityIdentifier("guidedMatch.army.\(army.id)")
                    }
                } header: {
                    Text(armiesSectionHeader(for: faction))
                } footer: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        if gameSystemId != .scTmg {
                            Text(
                                String(
                                    localized: """
                                    Badges show how much rules help is built in: army list, full setup options, or \
                                    in-battle ability reminders.
                                    """
                                )
                            )
                        }
                        if let army = sortedArmies.first(where: { $0.id == selectedArmyId }) {
                            Text(army.playstyle)
                        }
                    }
                }
            }

            if let army = sortedArmies.first(where: { $0.id == selectedArmyId }) {
                Section(String(localized: "Army Details")) {
                    LabeledContent(String(localized: "General"), value: army.general)
                    LabeledContent(String(localized: "Units"), value: "\(army.unitCount)")
                    Text(army.tagline)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if !army.roster.isEmpty {
                    Section(String(localized: "Roster")) {
                        ForEach(army.roster, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }

                if let battleTraitName = army.battleTraitName, !army.battleTraits.isEmpty {
                    Section(battleTraitName) {
                        ForEach(army.battleTraits) { trait in
                            ArmyRuleOptionCard(option: trait, isSelected: false)
                        }
                    }
                }

                if let urlString = army.officialRulesURL, let url = URL(string: urlString) {
                    Section(String(localized: "Official Rules")) {
                        Link(destination: url) {
                            Label(officialRulesLinkTitle, systemImage: "arrow.up.right.square")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guidedMatch.officialRules.\(army.id)")
                    }
                }

                if showsUnitReference(for: army) {
                    Section(String(localized: "Reference")) {
                        NavigationLink(value: ArmyRosterLink(
                            gameSystemId: gameSystemId.rawValue,
                            armyId: army.id
                        )) {
                            Label(unitReferenceLabel, systemImage: "doc.richtext")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guidedMatch.unitReference.\(army.id)")
                    }
                }
            }
        }
        .readableContentWidth()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save")) {
                    var updated = selection
                    updated.playerName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if updated.playerName.isEmpty {
                        updated.playerName = title
                    }
                    updated.factionId = selectedFactionId
                    updated.armyId = selectedArmyId
                    updated.regimentAbilityId = nil
                    updated.enhancementId = nil
                    updated.secondaryObjectiveId = nil
                    onSave(updated)
                    if dismissesOnSave {
                        dismiss()
                    }
                }
                .disabled(selectedFactionId.isEmpty || selectedArmyId.isEmpty)
                .accessibilityIdentifier("guidedMatch.saveArmy")
            }
        }
    }

    private var officialRulesLinkTitle: String {
        switch gameSystemId {
        case .scTmg:
            String(localized: "StarCraft TMG Rules")
        case .wh40k11e, .wh40k10eCp:
            String(localized: "Official Rules PDF")
        case .aosSpearhead:
            String(localized: "GW Spearhead PDF")
        }
    }

    private func armiesSectionHeader(for faction: SpearheadFaction) -> String {
        switch gameSystemId {
        case .scTmg:
            String(localized: "\(faction.name) Armies")
        case .wh40k11e, .wh40k10eCp:
            String(localized: "\(faction.name) Combat Patrols")
        case .aosSpearhead:
            String(localized: "\(faction.name) Spearheads")
        }
    }

    private var unitReferenceLabel: String {
        playContext.unitReferenceLinkTitle
    }

    private func showsUnitReference(for army: SpearheadArmy) -> Bool {
        if playContext.usesGuidedBattleTracker {
            return !army.units.isEmpty
        }
        return army.units.contains(where: \.hasWarscroll)
    }
}

private struct ArmyOptionRow: View {
    let army: SpearheadArmy
    let isSelected: Bool
    let featuredArmies: GuidedMatchFeaturedArmies
    var gameSystemId: GameSystemId = .default

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(army.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if featuredArmies.isFeatured(army.id) {
                        Text(String(localized: "Starter Set"))
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentOnSurface)
                    }
                }
                Text(army.general)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ContentCoverageBadge(coverage: army.contentCoverage, gameSystemId: gameSystemId)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(army.name), general \(army.general), \(army.contentCoverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue))"
        )
        .accessibilityHint(isSelected ? "Selected" : "Select this army")
    }
}

private struct ContentCoverageBadge: View {
    let coverage: SpearheadContentCoverage
    var gameSystemId: GameSystemId = .default

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        if playContext.capabilities.showsActivationBar {
            EmptyView()
        } else {
            Label(coverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue), systemImage: coverage.systemImage)
                .font(.caption2.weight(.medium))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, 2)
                .background(coverage >= .battleTracker ? Color.green.opacity(0.15) : Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(coverage >= .warscrolls ? .orange : coverage >= .battleTracker ? .green : .secondary)
                .accessibilityLabel(String(localized: "Content: \(coverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue))"))
        }
    }
}
