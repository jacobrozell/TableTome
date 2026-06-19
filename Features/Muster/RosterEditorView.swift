import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

@MainActor
struct RosterEditorView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
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
    @State private var shareText: String?

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

    var body: some View {
        Group {
            if let roster { editor(roster) }
            else { ContentUnavailableView(String(localized: "List not found"), systemImage: "flag") }
        }
    }

    @ViewBuilder
    private func editor(_ roster: Roster) -> some View {
        let pres = roster.presentation(overrides: overrides)
        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label ?? roster.battleSizeKey
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                CrestBadge(text: pres.crest, colorHex: pres.colorHex)
                                Spacer(minLength: 0)
                                if showsFieldableRing {
                                    ProgressRing(percent: fieldablePercent, diameter: 36)
                                }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(roster.faction)
                                    .font(.headline)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(sizeLabel)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            CrestBadge(text: pres.crest, colorHex: pres.colorHex)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(roster.faction)
                                    .font(.headline)
                                Text(sizeLabel)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            if showsFieldableRing {
                                ProgressRing(percent: fieldablePercent, diameter: 36)
                            }
                        }
                    }
                    if let army = linkedArmy(for: roster) {
                        Button {
                            router.openCollection(armyId: army.id)
                        } label: {
                            Label(String(localized: "Linked: \(army.name)"), systemImage: "link")
                                .font(dynamicTypeSize.isAccessibilitySize ? .subheadline : .caption)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .accessibilityLabel(String(localized: "Linked collection army \(army.name)"))
                        .accessibilityHint(String(localized: "Opens army in Collection tab"))
                    }
                    if !roster.notes.isEmpty {
                        Text(roster.notes).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                if roster.orderedEntries.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No units"), systemImage: "figure.stand")
                    } description: {
                        Text(String(localized: "Tap + to add units from the catalog."))
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
        .navigationTitle(roster.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            RosterPointsBar(roster: roster)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Add unit"), systemImage: "plus") { showCatalog = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ShareLink(item: RosterExport.plainText(roster: roster, overrides: overrides)) {
                        Label(String(localized: "Share…"), systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("musterShare")
                    Button(String(localized: "Duplicate"), systemImage: "doc.on.doc") { duplicate(roster) }
                    Button(String(localized: "Link army"), systemImage: "link") { showLinkArmy = true }
                    Button(String(localized: "Add missing to collection"), systemImage: "tray.and.arrow.down") {
                        addMissing(roster)
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
            RenameRosterSheet(current: roster.name) { newName in
                do { return try RosterStore.rename(roster, to: newName, in: context) }
                catch { return false }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showLinkArmy) {
            LinkArmySheet(roster: roster, armies: matchingArmies(for: roster)) { armyId in
                RosterStore.setLinkedArmy(roster, armyId: armyId, in: context)
            }
            .presentationDetents([.medium])
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

    private func linkedArmy(for roster: Roster) -> Army? {
        guard let id = roster.linkedArmyId else { return nil }
        return armies.first { $0.id == id }
    }

    private func matchingArmies(for roster: Roster) -> [Army] {
        armies.filter {
            $0.game == roster.game && FactionResolver.normalize($0.faction) == FactionResolver.normalize(roster.faction)
        }
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
}

private struct LinkArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    let roster: Roster
    let armies: [Army]
    let onSelect: (UUID?) -> Void

    @State private var selection: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Picker(String(localized: "Collection army"), selection: $selection) {
                    Text(String(localized: "None")).tag(UUID?.none)
                    ForEach(armies) { army in
                        Text(army.name).tag(Optional(army.id))
                    }
                }
                .formNavigationPickerStyle()
            }
            .navigationTitle(String(localized: "Link army"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        onSelect(selection)
                        dismiss()
                    }
                }
            }
            .onAppear { selection = roster.linkedArmyId }
        }
    }
}
