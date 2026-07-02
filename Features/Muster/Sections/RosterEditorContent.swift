import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct RosterEditorContent: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router

    let roster: Roster
    let overrides: [FactionPresetOverride]
    let armies: [Army]
    let matchByEntryId: [UUID: CollectionMatchResult]
    let fieldablePercent: Int
    let showsFieldableRing: Bool
    let ownershipCounts: (owned: Int, partial: Int, missing: Int)
    let syncStatus: RosterCatalogSync.Status
    let linkedArmy: Army?
    let matchingArmies: [Army]
    let catalogNeedsRefresh: Bool

    @Binding var showCatalog: Bool
    @Binding var entrySheet: RosterEntry?
    @Binding var showRename: Bool
    @Binding var showLinkArmy: Bool
    @Binding var confirmDelete: Bool

    let onPlayWithList: () -> Void
    let onDuplicate: () -> Void
    let onAddMissing: () -> Void
    let onRefreshCatalogPoints: () -> Void

    var body: some View {
        let pres = roster.presentation(overrides: overrides)
        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label ?? roster.battleSizeKey
        let pointsTotal = RosterPoints.total(roster.orderedEntries)
        let pointsLimit = RosterPoints.limit(for: roster)
        let isOverLimit = RosterPoints.isOverLimit(roster)

        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                                Spacer(minLength: 0)
                                if showsFieldableRing {
                                    RosterFieldableSummary(
                                        fieldablePercent: fieldablePercent,
                                        ownershipCounts: ownershipCounts
                                    )
                                }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(roster.faction)
                                    .font(.headline)
                                    .fixedSize(horizontal: false, vertical: true)
                                HStack(spacing: 5) {
                                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .accessibilityHidden(true)
                                    Text(sizeLabel)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(roster.faction)
                                    .font(.headline)
                                HStack(spacing: 5) {
                                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .accessibilityHidden(true)
                                    Text(sizeLabel)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer(minLength: 8)
                            if showsFieldableRing {
                                RosterFieldableSummary(
                                    fieldablePercent: fieldablePercent,
                                    ownershipCounts: ownershipCounts
                                )
                            }
                        }
                    }
                    if isOverLimit {
                        RosterOverLimitBanner(total: pointsTotal, limit: pointsLimit)
                    } else if pointsLimit > 0, !roster.orderedEntries.isEmpty {
                        RosterPointsStatusLine(
                            total: pointsTotal,
                            limit: pointsLimit,
                            remaining: RosterPoints.remaining(for: roster)
                        )
                    }
                    if syncStatus.needsRefresh {
                        RosterStalePointsBanner(status: syncStatus, onRefresh: onRefreshCatalogPoints)
                    }
                    if let army = linkedArmy {
                        Button {
                            router.openCollection(armyId: army.id)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .foregroundStyle(Color.accentOnSurface)
                                    .symbolRenderingMode(.hierarchical)
                                Text(String(localized: "Linked: \(army.name)"))
                                    .font(dynamicTypeSize.isAccessibilitySize ? .subheadline : .caption)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(String(localized: "Linked collection army \(army.name)"))
                        .accessibilityHint(String(localized: "Opens army in Collection tab"))
                    }
                    if !roster.notes.isEmpty {
                        Text(roster.notes).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } footer: {
                if !roster.orderedEntries.isEmpty {
                    PointsSourceViews.catalogAttributionFootnote(
                        RosterCatalogSync.catalogAttribution,
                        customOverrideCount: syncStatus.customOverrideCount
                    )
                }
            }
            Section {
                if roster.orderedEntries.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No units"), systemImage: "figure.stand")
                    } description: {
                        Text(String(localized: "Add units from the catalog to count points and track ownership."))
                    } actions: {
                        Button(String(localized: "Add unit"), systemImage: "plus") { showCatalog = true }
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(roster.orderedEntries) { entry in
                        RosterEntryRow(entry: entry, roster: roster,
                                       match: matchByEntryId[entry.id]) {
                            entrySheet = entry
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let entry = roster.orderedEntries[index]
                            RosterStore.deleteEntry(entry, in: context)
                        }
                    }
                }
            } header: {
                Text(String(localized: "Units"))
            } footer: {
                if roster.linkedArmyId == nil, ReleaseSurface.showsBenchTab {
                    Text(
                        String(
                            localized: """
                            Link this list to a Models army to see which units you own. Use List actions → Link army.
                            """
                        )
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .readableContentWidth()
        .navigationTitle(roster.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            RosterPointsBar(roster: roster)
        }
        .toolbar {
            if ReleaseSurface.showsPlayFromRoster, roster.game == "40k" {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onPlayWithList()
                    } label: {
                        Label(String(localized: "Play with this list"), systemImage: "play.circle")
                    }
                    .accessibilityIdentifier("rosterEditor.playWithList")
                    .accessibilityHint(
                        String(localized: "Opens Guided Match on the Play tab for this army list.")
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Add unit"), systemImage: "plus") { showCatalog = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: RosterExport.plainText(roster: roster, overrides: overrides)) {
                        Label(String(localized: "Share…"), systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("musterShare")
                    Button(String(localized: "Duplicate"), systemImage: "doc.on.doc") { onDuplicate() }
                    Button(String(localized: "Link army"), systemImage: "link") { showLinkArmy = true }
                    Button(String(localized: "Add missing to collection"), systemImage: "tray.and.arrow.down") {
                        onAddMissing()
                    }
                    if catalogNeedsRefresh {
                        Button(String(localized: "Update points from catalog"), systemImage: "arrow.triangle.2.circlepath") {
                            onRefreshCatalogPoints()
                        }
                    }
                    Divider()
                    Button(String(localized: "Rename"), systemImage: "pencil") { showRename = true }
                    Button(String(localized: "Delete list"), systemImage: "trash", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(String(localized: "List actions"))
            }
        }
        .sheet(isPresented: $showCatalog) {
            UnitCatalogBrowser(roster: roster) { unit in
                _ = try? RosterStore.addEntry(from: unit.id, to: roster, in: context)
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: Binding(
            get: { entrySheet != nil },
            set: { if !$0 { entrySheet = nil } }
        )) {
            if let entry = entrySheet {
                RosterEntrySheet(entry: entry)
            }
        }
        .sheet(isPresented: $showRename) {
            RenameRosterSheet(roster: roster, overrides: overrides, current: roster.name) { newName in
                do { return try RosterStore.rename(roster, to: newName, in: context) }
                catch { return false }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showLinkArmy) {
            LinkArmySheet(
                roster: roster,
                armies: matchingArmies,
                overrides: overrides
            ) { armyId in
                RosterStore.setLinkedArmy(roster, armyId: armyId, in: context)
            }
            .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            String(localized: "Delete \"\(roster.name)\"?"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                RosterStore.delete(roster, in: context)
                dismiss()
            }
        }
    }
}
