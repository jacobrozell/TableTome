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
                RenameRosterSheet(current: roster.name) { newName in
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
            if usesPadSidebarList {
                List(filtered, selection: $selectedRosterId) { roster in
                    rosterRowContent(roster)
                }
                .listStyle(.sidebar)
            } else {
                List(filtered) { roster in
                    rosterRowContent(roster)
                }
                .listStyle(.insetGrouped)
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
        pres: (crest: String, colorHex: String),
        total: Int,
        limit: Int,
        fieldable: Int,
        showsFieldable: Bool
    ) -> some View {
        HStack(spacing: 12) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex)
            VStack(alignment: .leading, spacing: 2) {
                Text(roster.name)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(String(localized: "\(roster.faction) · \(total) / \(limit) pts"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        pres: (crest: String, colorHex: String),
        total: Int,
        limit: Int,
        fieldable: Int,
        showsFieldable: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                CrestBadge(text: pres.crest, colorHex: pres.colorHex)
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
            Text(String(localized: "\(roster.faction) · \(total) / \(limit) pts"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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
    let current: String
    let onRename: (String) -> Bool

    @State private var name: String
    @State private var error = false

    init(current: String, onRename: @escaping (String) -> Bool) {
        self.current = current
        self.onRename = onRename
        _name = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormNameField(title: String(localized: "List name"), text: $name, focus: $nameFocused)
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That name is taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .navigationTitle(String(localized: "Rename list"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { if onRename(name) { dismiss() } else { error = true } }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
    }
}
