import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

@MainActor
struct RosterEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Environment(BannerCenter.self) private var banner
    @Query private var rosters: [Roster]
    @Query(sort: \Army.sortIndex) private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    let rosterId: UUID

    @State private var showCatalog = false
    @State private var entrySheet: RosterEntry?
    @State private var showRename = false
    @State private var showLinkArmy = false
    @State private var confirmDelete = false

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var overrides: [FactionPresetOverride] { cfg.factionOverrides }
    private var pipeline: [PipelineStage] { Pipeline.resolve(cfg.globalPipeline) }
    private var roster: Roster? { rosters.first { $0.id == rosterId } }

    private var matches: [(RosterEntry, CollectionMatchResult)] {
        guard let roster else { return [] }
        return CollectionMatcher.matchAll(roster: roster, armies: armies, in: context)
    }

    private var matchByEntryId: [UUID: CollectionMatchResult] {
        Dictionary(uniqueKeysWithValues: matches.map { ($0.0.id, $0.1) })
    }

    private var fieldablePercent: Int {
        guard let roster else { return 0 }
        return CollectionMatcher.fieldablePercent(roster: roster, armies: armies, in: context)
    }

    private var showsFieldableRing: Bool {
        guard let roster else { return false }
        guard !roster.entries.isEmpty else { return false }
        if roster.linkedArmyId != nil { return true }
        let f = FactionResolver.normalize(roster.faction)
        return armies.contains { $0.game == roster.game && FactionResolver.normalize($0.faction) == f }
    }

    private var ownershipCounts: (owned: Int, partial: Int, missing: Int) {
        var owned = 0, partial = 0, missing = 0
        for (_, match) in matches {
            switch match.status {
            case .owned: owned += 1
            case .partial: partial += 1
            case .missing: missing += 1
            case .unknown: break
            }
        }
        return (owned, partial, missing)
    }

    private func catalogSyncStatus(for roster: Roster) -> RosterCatalogSync.Status {
        let snapshots = roster.orderedEntries.map {
            RosterCatalogSync.EntrySnapshot(
                catalogUnitId: $0.catalogUnitId,
                pointsEach: $0.pointsEach,
                usesCustomPoints: $0.usesCustomPoints
            )
        }
        return RosterCatalogSync.status(entries: snapshots, rosterCatalogVersion: roster.catalogVersion)
    }

    var body: some View {
        Group {
            if let roster {
                RosterEditorContent(
                    roster: roster,
                    overrides: overrides,
                    armies: armies,
                    matchByEntryId: matchByEntryId,
                    fieldablePercent: fieldablePercent,
                    showsFieldableRing: showsFieldableRing,
                    ownershipCounts: ownershipCounts,
                    syncStatus: catalogSyncStatus(for: roster),
                    linkedArmy: linkedArmy(for: roster),
                    matchingArmies: matchingArmies(for: roster),
                    catalogNeedsRefresh: catalogSyncStatus(for: roster).needsRefresh,
                    showCatalog: $showCatalog,
                    entrySheet: $entrySheet,
                    showRename: $showRename,
                    showLinkArmy: $showLinkArmy,
                    confirmDelete: $confirmDelete,
                    onPlayWithList: { playWithList(roster) },
                    onDuplicate: { duplicate(roster) },
                    onAddMissing: { addMissing(roster) },
                    onRefreshCatalogPoints: { refreshCatalogPoints(roster) }
                )
            } else {
                ContentUnavailableView {
                    Label(String(localized: "List not found"), systemImage: "flag")
                } description: {
                    Text(String(localized: "This list may have been deleted."))
                }
            }
        }
    }

    private func linkedArmy(for roster: Roster) -> Army? {
        guard let id = roster.linkedArmyId else { return nil }
        return armies.first { $0.id == id }
    }

    private func matchingArmies(for roster: Roster) -> [Army] {
        armies.filter {
            $0.game == roster.game && FactionResolver.normalize($0.faction) == FactionResolver.normalize(roster.faction)
        }
    }

    private func playWithList(_ roster: Roster) {
        let gameSystemId = guidedMatchGameSystemId(for: roster)
        router.openGuidedMatch(gameSystemId: gameSystemId)
    }

    private func guidedMatchGameSystemId(for roster: Roster) -> String {
        if let size = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey),
           size.id == "combat-patrol" {
            return GameSystemId.wh40k10eCp.rawValue
        }
        return GameSystemId.wh40k11e.rawValue
    }

    private func duplicate(_ roster: Roster) {
        do {
            let copy = try RosterStore.duplicate(roster, in: context)
            router.openMuster(rosterId: copy.id)
            banner.show(String(localized: "Duplicated \"\(copy.name)\""))
        } catch {
            banner.show(String(localized: "Could not duplicate list"))
        }
    }

    private func addMissing(_ roster: Roster) {
        do {
            let n = try RosterStore.importMissingToCollection(roster: roster, pipeline: pipeline, in: context)
            if n > 0 {
                banner.show(String(localized: "Added \(n) unit\(n == 1 ? "" : "s") to collection"))
            } else {
                banner.show(String(localized: "Nothing to add"))
            }
        } catch {
            banner.show(String(localized: "Could not add missing units"))
        }
    }

    private func refreshCatalogPoints(_ roster: Roster) {
        let result = RosterStore.refreshCatalogPoints(for: roster, in: context)
        if result.updated > 0 {
            banner.show(
                String(localized: "Updated points for \(result.updated) unit\(result.updated == 1 ? "" : "s")")
            )
        } else if result.missing > 0 {
            banner.show(String(localized: "Catalog is current; \(result.missing) unit\(result.missing == 1 ? "" : "s") not in catalog"))
        } else {
            banner.show(String(localized: "Points already match catalog"))
        }
    }
}
