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
    var profiles: [PlayerProfile] = []
    var primaryProfileId: UUID?
    var profileSlotLabel: String = ""
    var opponentArmyId: String?
    var isPlayerOne: Bool = false
    let onSave: (PlayerArmySelection) -> Void

    @State var playerName: String
    @State var selectedProfileId: UUID?
    @State var selectedFactionId: String
    @State var selectedArmyId: String
    @State var showsAllCatalogArmies = false
    @State var armySearchText = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var enablesProfilePicker: Bool {
        ReleaseSurface.showsPlayersHub && !profiles.isEmpty
    }

    init(
        title: String,
        selection: PlayerArmySelection,
        factions: [SpearheadFaction],
        featuredArmies: GuidedMatchFeaturedArmies = GuidedMatchFeaturedArmies.resolved(for: .default),
        ruleSections: [RuleSection] = [],
        gameSystemId: GameSystemId = .default,
        dismissesOnSave: Bool = true,
        profiles: [PlayerProfile] = [],
        primaryProfileId: UUID? = nil,
        profileSlotLabel: String = "",
        opponentArmyId: String? = nil,
        isPlayerOne: Bool = false,
        onSave: @escaping (PlayerArmySelection) -> Void
    ) {
        self.title = title
        self.selection = selection
        self.factions = factions
        self.featuredArmies = featuredArmies
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
        self.dismissesOnSave = dismissesOnSave
        self.profiles = profiles
        self.primaryProfileId = primaryProfileId
        self.profileSlotLabel = profileSlotLabel
        self.opponentArmyId = opponentArmyId
        self.isPlayerOne = isPlayerOne
        self.onSave = onSave
        _playerName = State(initialValue: selection.playerName)
        _selectedProfileId = State(initialValue: selection.profileId)
        _selectedFactionId = State(initialValue: selection.factionId)
        _selectedArmyId = State(initialValue: selection.armyId)
    }

    init(
        title: String,
        selection: PlayerArmySelection,
        factions: [SpearheadFaction],
        featuredArmies: GuidedMatchFeaturedArmies = GuidedMatchFeaturedArmies.resolved(for: .default),
        ruleSections: [RuleSection] = [],
        gameSystemId: String,
        dismissesOnSave: Bool = true,
        profiles: [PlayerProfile] = [],
        primaryProfileId: UUID? = nil,
        profileSlotLabel: String = "",
        opponentArmyId: String? = nil,
        isPlayerOne: Bool = false,
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
            profiles: profiles,
            primaryProfileId: primaryProfileId,
            profileSlotLabel: profileSlotLabel,
            opponentArmyId: opponentArmyId,
            isPlayerOne: isPlayerOne,
            onSave: onSave
        )
    }

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var selectedProfile: PlayerProfile? {
        guard let selectedProfileId else { return nil }
        return profiles.first { $0.id == selectedProfileId }
    }

    private var ownedArmyIds: Set<String> {
        guard let selectedProfile else { return [] }
        return OwnedArmyResolver.ownedArmyIds(for: selectedProfile)
    }

    var body: some View {
        factionPickList
            .navigationDestination(for: FactionPickLink.self) { link in
                armyPickLevel(factionId: link.factionId)
            }
            .searchable(
                text: $armySearchText,
                prompt: String(localized: "Search factions or armies")
            )
            .ttScreenBackground()
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(TTColor.player(isPlayerOne))
                    .frame(height: 4)
                    .ignoresSafeArea(edges: .horizontal)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "guidedMatch.saveArmy", placement: .confirmationAction) {
                    Button(dismissesOnSave ? String(localized: "Done") : String(localized: "Save")) {
                        saveArmy()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedFactionId.isEmpty || selectedArmyId.isEmpty)
                    .accessibilityIdentifier("guidedMatch.saveArmy")
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
    }

    func saveArmy() {
        var updated = selection
        updated.playerName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if updated.playerName.isEmpty {
            updated.playerName = title
        }
        updated.profileId = selectedProfileId
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

    var trimmedArmySearch: String {
        armySearchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func factionMatches(_ faction: SpearheadFaction) -> Bool {
        faction.name.localizedCaseInsensitiveContains(trimmedArmySearch)
    }

    func armyMatches(_ army: SpearheadArmy) -> Bool {
        army.name.localizedCaseInsensitiveContains(trimmedArmySearch)
            || army.general.localizedCaseInsensitiveContains(trimmedArmySearch)
    }

    func armies(for faction: SpearheadFaction) -> [SpearheadArmy] {
        let base = faction.armies.sorted { lhs, rhs in
            let leftFeatured = featuredArmies.isFeatured(lhs.id)
            let rightFeatured = featuredArmies.isFeatured(rhs.id)
            if leftFeatured != rightFeatured { return leftFeatured && !rightFeatured }
            return lhs.name < rhs.name
        }
        guard enablesProfilePicker, !ownedArmyIds.isEmpty, !showsAllCatalogArmies else { return base }
        return OwnedArmyResolver.filtersArmies(base, ownedIds: ownedArmyIds).owned
    }

    func hiddenArmies(for faction: SpearheadFaction) -> [SpearheadArmy] {
        guard enablesProfilePicker, !ownedArmyIds.isEmpty else { return [] }
        let base = faction.armies.sorted { $0.name < $1.name }
        return OwnedArmyResolver.filtersArmies(base, ownedIds: ownedArmyIds).other
    }

    func select(army: SpearheadArmy, faction: SpearheadFaction) {
        selectedFactionId = faction.id
        selectedArmyId = army.id
    }

    var unitReferenceLabel: String {
        playContext.unitReferenceLinkTitle
    }

    func showsUnitReference(for army: SpearheadArmy) -> Bool {
        if playContext.usesGuidedBattleTracker {
            return !army.units.isEmpty
        }
        return army.units.contains(where: \.hasWarscroll)
    }

    func applyPreferredArmy(for profile: PlayerProfile) {
        if let opponentArmyId, !opponentArmyId.isEmpty,
           let preferredId = profile.guidedMatchPreferences.preferredArmyIdByOpponentArmyId[opponentArmyId],
           let faction = factions.first(where: { $0.armies.contains(where: { $0.id == preferredId }) }) {
            selectedFactionId = faction.id
            selectedArmyId = preferredId
            return
        }

        if let armyId = profile.ownedSpearheadArmyIds.first,
           let faction = factions.first(where: { $0.armies.contains(where: { $0.id == armyId }) }) {
            selectedFactionId = faction.id
            selectedArmyId = armyId
        }
    }
}
