import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

@MainActor
struct MusterHomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Environment(BannerCenter.self) private var banner
    @Query(sort: \Roster.sortIndex) private var rosters: [Roster]
    @Query(sort: \Army.sortIndex) private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    @Binding var selectedRosterId: UUID?
    @Binding var showNewRoster: Bool
    var preferSidebarSelection: Bool = false
    var onSelectRoster: (UUID) -> Void = { _ in }

    @State private var search = ""
    @State private var rosterToRename: Roster?
    @State private var rosterToDelete: Roster?

    private var overrides: [FactionPresetOverride] { configs.first?.factionOverrides ?? [] }
    private var filtered: [Roster] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return rosters }
        return rosters.filter {
            $0.name.lowercased().contains(q) || $0.faction.lowercased().contains(q)
        }
    }
    private var usesPadSidebarList: Bool {
        AdaptiveLayout.usesSidebarListStyle(horizontalSizeClass, preferSelection: preferSidebarSelection)
    }

    var body: some View {
        Group {
            if rosters.isEmpty { emptyState }
            else { listContent }
        }
        .navigationTitle(String(localized: "Army Lists"))
        .searchable(text: $search, prompt: String(localized: "Lists, factions…"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "New list"), systemImage: "plus") { showNewRoster = true }
                    .accessibilityIdentifier("musterNewList")
            }
        }
        .sheet(isPresented: Binding(
            get: { rosterToRename != nil },
            set: { if !$0 { rosterToRename = nil } }
        )) {
            if let roster = rosterToRename {
                RenameRosterSheet(roster: roster, overrides: overrides, current: roster.name) { newName in
                    do {
                        return try RosterStore.rename(roster, to: newName, in: context)
                    } catch {
                        return false
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .confirmationDialog(
            String(localized: "Delete \"\(rosterToDelete?.name ?? "")\"?"),
            isPresented: Binding(get: { rosterToDelete != nil },
                                 set: { if !$0 { rosterToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                if let roster = rosterToDelete {
                    if roster.id == selectedRosterId { selectedRosterId = nil }
                    RosterStore.delete(roster, in: context)
                }
                rosterToDelete = nil
            }
            Button(String(localized: "Cancel"), role: .cancel) { rosterToDelete = nil }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No lists yet"), systemImage: "flag")
        } description: {
            Text(
                String(
                    localized: """
                    Army lists count points and show what you can field. Optional until you build a larger collection — \
                    link a list to Models to see which units you own.
                    """
                )
            )
        } actions: {
            Button(String(localized: "New list"), systemImage: "plus") { showNewRoster = true }
                .accessibilityIdentifier("musterNewList")
        }
        .adaptiveEmptyStateLayout()
    }

    private var listContent: some View {
        Group {
            if filtered.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: "No matching lists"), systemImage: "magnifyingglass")
                } description: {
                    Text(String(localized: "Nothing matches your search."))
                } actions: {
                    Button(String(localized: "Clear search")) { search = "" }
                        .buttonStyle(.borderedProminent)
                }
                .adaptiveEmptyStateLayout()
            } else {
                listBody
            }
        }
    }

    @ViewBuilder
    private var listBody: some View {
        if usesPadSidebarList {
            List(selection: $selectedRosterId) {
                listSections
            }
            .listStyle(.sidebar)
            .tabBarScrollInset()
        } else {
            List {
                listSections
            }
            .listStyle(.insetGrouped)
            .tabBarScrollInset()
        }
    }

    @ViewBuilder
    private var listSections: some View {
        if !armies.isEmpty {
            Section {
                Button {
                    router.tab = .armies
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.title3)
                            .foregroundStyle(Color.accentOnSurface)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 28)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "Link a Models army"))
                                .font(.subheadline.weight(.medium))
                            Text(
                                String(
                                    localized: "Track which roster units you own and field."
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        Section {
            ForEach(filtered) { roster in
                rosterRowContent(roster)
            }
        }
    }

    @ViewBuilder
    private func rosterRowContent(_ roster: Roster) -> some View {
        rosterRow(roster)
            .tag(roster.id)
            .listSidebarSelection(isSelected: selectedRosterId == roster.id,
                                  enabled: usesPadSidebarList)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelectRoster(roster.id)
            }
            .contextMenu {
                Button(String(localized: "Duplicate"), systemImage: "doc.on.doc") {
                    duplicate(roster)
                }
                Button(String(localized: "Rename"), systemImage: "pencil") { rosterToRename = roster }
                Button(String(localized: "Delete"), systemImage: "trash", role: .destructive) { rosterToDelete = roster }
            }
    }

    @ViewBuilder
    private func rosterRow(_ roster: Roster) -> some View {
        let pres = roster.presentation(overrides: overrides)
        let total = RosterPoints.total(roster.orderedEntries)
        let limit = RosterPoints.limit(for: roster)
        let fieldable = CollectionMatcher.fieldablePercent(roster: roster, armies: armies, in: context)
        let showsFieldable = roster.linkedArmyId != nil || armies.contains {
            $0.game == roster.game && FactionResolver.normalize($0.faction) == FactionResolver.normalize(roster.faction)
        }
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                stackedRosterRow(
                    roster: roster, pres: pres, total: total, limit: limit,
                    fieldable: fieldable, showsFieldable: showsFieldable
                )
            } else {
                compactRosterRow(
                    roster: roster, pres: pres, total: total, limit: limit,
                    fieldable: fieldable, showsFieldable: showsFieldable
                )
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rosterAccessibilityLabel(
            roster: roster, total: total, limit: limit, fieldable: fieldable, showsFieldable: showsFieldable
        ))
        .accessibilityHint(String(localized: "Opens list editor"))
    }

    private func compactRosterRow(
        roster: Roster,
        pres: FactionPresentation,
        total: Int,
        limit: Int,
        fieldable: Int,
        showsFieldable: Bool
    ) -> some View {
        HStack(spacing: 12) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(roster.name)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 5) {
                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text(String(localized: "\(roster.faction) · \(total) / \(limit) pts"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            if !roster.entries.isEmpty, showsFieldable {
                ProgressRing(percent: fieldable, diameter: 32)
                    .accessibilityLabel(String(localized: "\(fieldable) percent fieldable"))
            }
        }
    }

    private func stackedRosterRow(
        roster: Roster,
        pres: FactionPresentation,
        total: Int,
        limit: Int,
        fieldable: Int,
        showsFieldable: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                Spacer(minLength: 0)
                if !roster.entries.isEmpty, showsFieldable {
                    ProgressRing(percent: fieldable, diameter: 32)
                        .accessibilityLabel(String(localized: "\(fieldable) percent fieldable"))
                }
            }
            Text(roster.name)
                .font(.headline)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 5) {
                Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
                Text(String(localized: "\(roster.faction) · \(total) / \(limit) pts"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func rosterAccessibilityLabel(
        roster: Roster, total: Int, limit: Int, fieldable: Int, showsFieldable: Bool
    ) -> String {
        var label = String(localized: "\(roster.name), \(roster.faction), \(total) of \(limit) points")
        if showsFieldable { label += String(localized: ", \(fieldable) percent fieldable") }
        return label
    }

    private func duplicate(_ roster: Roster) {
        do {
            let copy = try RosterStore.duplicate(roster, in: context)
            banner.show(String(localized: "Duplicated \"\(copy.name)\""))
        } catch {
            banner.show(String(localized: "Could not duplicate list"))
        }
    }
}

struct RenameRosterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    let roster: Roster?
    let overrides: [FactionPresetOverride]
    let current: String
    let onRename: (String) -> Bool

    @State private var name: String
    @State private var error = false

    init(
        roster: Roster? = nil,
        overrides: [FactionPresetOverride] = [],
        current: String,
        onRename: @escaping (String) -> Bool
    ) {
        self.roster = roster
        self.overrides = overrides
        self.current = current
        self.onRename = onRename
        _name = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let roster {
                    Section {
                        let pres = roster.presentation(overrides: overrides)
                        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label
                            ?? roster.battleSizeKey
                        HStack(spacing: 12) {
                            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(roster.name)
                                    .font(.headline)
                                HStack(spacing: 5) {
                                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .accessibilityHidden(true)
                                    Text("\(roster.faction) · \(sizeLabel)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    FormNameField(title: String(localized: "List name"), text: $name, focus: $nameFocused)
                } header: {
                    Text(String(localized: "Name"))
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That name is taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "Rename list"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { if onRename(name) { dismiss() } else { error = true } }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
            .onAppear { nameFocused = true }
        }
    }
}
