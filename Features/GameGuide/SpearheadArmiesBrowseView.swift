import SwiftUI
import TabletomeDomain

struct SpearheadArmiesBrowseLink: Hashable {
    let gameSystemId: String
}

struct SpearheadArmiesBrowseView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    let gameSystemId: String

    @State private var factions: [SpearheadFaction] = []
    @State private var query = ""

    private var featuredIds: Set<String> {
        GuidedMatchFeaturedArmies.resolved(for: gameSystemId).armyIds
    }

    var body: some View {
        List {
            if !starterRows.isEmpty {
                Section {
                    ForEach(starterRows, id: \.army.id) { row in
                        armyLink(row.army, factionName: row.factionName)
                    }
                } header: {
                    TTSectionHeader(String(localized: "Starter Armies"))
                }
            }
            Section {
                ForEach(filteredFactions) { faction in
                    DisclosureGroup(faction.name) {
                        ForEach(visibleArmies(in: faction)) { army in
                            armyLink(army, factionName: faction.name)
                        }
                    }
                }
            } header: {
                TTSectionHeader(String(localized: "All Factions"))
            }
        }
        .ttGroupedList()
        .searchable(text: $query, prompt: String(localized: "Search armies or factions"))
        .navigationTitle(String(localized: "Spearhead Armies"))
        .accessibilityIdentifier("armies.browse")
        .task { await load() }
    }

    private var starterRows: [(factionName: String, army: SpearheadArmy)] {
        factions.flatMap { faction in
            faction.armies
                .filter { featuredIds.contains($0.id) && matches($0, faction: faction.name) }
                .map { (faction.name, $0) }
        }
    }

    private var filteredFactions: [SpearheadFaction] {
        factions.filter { faction in
            !visibleArmies(in: faction).isEmpty
        }
    }

    private func visibleArmies(in faction: SpearheadFaction) -> [SpearheadArmy] {
        faction.armies.filter { matches($0, faction: faction.name) }
    }

    private func matches(_ army: SpearheadArmy, faction: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        if faction.localizedCaseInsensitiveContains(trimmed) { return true }
        if army.name.localizedCaseInsensitiveContains(trimmed) { return true }
        return army.roster.contains { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    private func armyLink(_ army: SpearheadArmy, factionName: String) -> some View {
        NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: army.id)) {
            TTRow(title: army.name, subtitle: army.tagline.isEmpty ? factionName : army.tagline, systemImage: "shield.lefthalf.filled")
        }
        .accessibilityIdentifier("armies.row.\(army.id)")
    }

    private func load() async {
        let id = GameSystemId(resolving: gameSystemId)
        factions = (try? await dependencies.catalogRepository(for: id).loadCatalog().factions) ?? []
    }
}
