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
            if let roster { editor(roster) }
            else {
                ContentUnavailableView {
                    Label(String(localized: "List not found"), systemImage: "flag")
                } description: {
                    Text(String(localized: "This list may have been deleted."))
                }
            }
        }
    }

    @ViewBuilder
    private func editor(_ roster: Roster) -> some View {
        let pres = roster.presentation(overrides: overrides)
        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label ?? roster.battleSizeKey
        let pointsTotal = RosterPoints.total(roster.orderedEntries)
        let pointsLimit = RosterPoints.limit(for: roster)
        let isOverLimit = RosterPoints.isOverLimit(roster)
        let syncStatus = catalogSyncStatus(for: roster)
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                                Spacer(minLength: 0)
                                if showsFieldableRing {
                                    fieldableSummary
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
                                fieldableSummary
                            }
                        }
                    }
                    if isOverLimit {
                        overLimitBanner(total: pointsTotal, limit: pointsLimit)
                    } else if pointsLimit > 0, !roster.orderedEntries.isEmpty {
                        pointsStatusLine(total: pointsTotal, limit: pointsLimit, remaining: RosterPoints.remaining(for: roster))
                    }
                    if syncStatus.needsRefresh {
                        stalePointsBanner(syncStatus, roster: roster)
                    }
                    if let army = linkedArmy(for: roster) {
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
                        playWithList(roster)
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
                    Button(String(localized: "Duplicate"), systemImage: "doc.on.doc") { duplicate(roster) }
                    Button(String(localized: "Link army"), systemImage: "link") { showLinkArmy = true }
                    Button(String(localized: "Add missing to collection"), systemImage: "tray.and.arrow.down") {
                        addMissing(roster)
                    }
                    if catalogSyncStatus(for: roster).needsRefresh {
                        Button(String(localized: "Update points from catalog"), systemImage: "arrow.triangle.2.circlepath") {
                            refreshCatalogPoints(roster)
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
                armies: matchingArmies(for: roster),
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

    @ViewBuilder
    private var fieldableSummary: some View {
        let counts = ownershipCounts
        VStack(alignment: .trailing, spacing: 4) {
            ProgressRing(percent: fieldablePercent, diameter: 36)
                .accessibilityLabel(String(localized: "\(fieldablePercent) percent fieldable"))
            if counts.owned + counts.partial + counts.missing > 0 {
                Text(ownershipSummaryLine(counts))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func ownershipSummaryLine(_ counts: (owned: Int, partial: Int, missing: Int)) -> String {
        var parts: [String] = []
        if counts.owned > 0 {
            parts.append(String(localized: "\(counts.owned) owned"))
        }
        if counts.partial > 0 {
            parts.append(String(localized: "\(counts.partial) partial"))
        }
        if counts.missing > 0 {
            parts.append(String(localized: "\(counts.missing) missing"))
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private func stalePointsBanner(_ status: RosterCatalogSync.Status, roster: Roster) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Points update available"))
                    .font(.subheadline.weight(.semibold))
                if status.driftCount > 0 {
                    Text(
                        String(
                            localized: """
                            \(status.driftCount) unit\(status.driftCount == 1 ? "" : "s") differ from catalog \
                            (MFM \(status.catalogPointsKey)).
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    if status.customOverrideCount > 0 {
                        HStack(spacing: 6) {
                            PointsSourceViews.customPointsBadge(compact: true)
                            Text(
                                String(
                                    localized: """
                                    \(status.customOverrideCount) custom value\(status.customOverrideCount == 1 ? "" : "s") \
                                    will be left unchanged.
                                    """
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else if status.hasVersionDrift {
                    Text(
                        String(
                            localized: """
                            Catalog updated to \(status.catalogVersion) — refresh list points to match GW values.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text(String(localized: "Some units are no longer in the catalog."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button(String(localized: "Update now"), systemImage: "arrow.triangle.2.circlepath") {
                    refreshCatalogPoints(roster)
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .padding(.top, 2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "Points update available from catalog"))
    }

    @ViewBuilder
    private func overLimitBanner(total: Int, limit: Int) -> some View {
        let overBy = total - limit
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.red)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Over point limit"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                Text(
                    String(
                        localized: """
                        \(total) / \(limit) pts (\(overBy) over) — remove units or lower quantities.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(localized: "Over point limit, \(total) of \(limit) points, \(overBy) over limit")
        )
    }

    @ViewBuilder
    private func pointsStatusLine(total: Int, limit: Int, remaining: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            Text(String(localized: "\(total) / \(limit) pts · \(remaining) remaining"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .accessibilityLabel(String(localized: "\(total) of \(limit) points, \(remaining) remaining"))
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

private struct LinkArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    let roster: Roster
    let armies: [Army]
    let overrides: [FactionPresetOverride]
    let onSelect: (UUID?) -> Void

    @State private var selection: UUID?

    var body: some View {
        NavigationStack {
            Form {
                if armies.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(String(localized: "No matching armies"), systemImage: "shield")
                        } description: {
                            Text(
                                String(
                                    localized: """
                                    Add a \(roster.faction) army in Collection first, then link it here.
                                    """
                                )
                            )
                        }
                        .adaptiveEmptyStateLayout()
                    }
                } else {
                    Section {
                        Picker(String(localized: "Collection army"), selection: $selection) {
                            Text(String(localized: "None")).tag(UUID?.none)
                            ForEach(armies) { army in
                                armyPickerRow(army).tag(Optional(army.id))
                            }
                        }
                        .formNavigationPickerStyle()
                    } header: {
                        Text(String(localized: "Link to Models"))
                    } footer: {
                        Text(FormHints.rosterLink)
                    }
                }
            }
            .navigationTitle(String(localized: "Link army"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        onSelect(selection)
                        dismiss()
                    }
                    .disabled(armies.isEmpty)
                }
            }
            .onAppear { selection = roster.linkedArmyId }
        }
    }

    @ViewBuilder
    private func armyPickerRow(_ army: Army) -> some View {
        let pres = army.presentation(overrides: overrides)
        HStack(spacing: 10) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(army.name)
                    .lineLimit(1)
                Text(army.faction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
