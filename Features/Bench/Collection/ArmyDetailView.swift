import SwiftUI
import SwiftData
import TipKit
import TabletomeHobbyData
import TabletomeDomain

/// One army's units: native list with swipe actions and drill-down to unit detail.
@MainActor
struct ArmyDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Environment(BannerCenter.self) private var banner
    @Query private var configs: [AppConfiguration]
    @Query private var allArmies: [Army]

    let armyId: UUID
    @Binding var selectedArmyId: UUID?
    @Binding var selectedUnitId: UUID?
    var preferSidebarSelection: Bool = false
    var onSelectUnit: (UUID) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss

    @State private var showAddUnit = false
    @State private var showRename = false
    @State private var showPipeline = false
    @State private var confirmDeleteArmy = false
    @State private var unitToDelete: ArmyUnit?
    @State private var advanceTrigger = false
    @State private var isEditing = false
    @State private var batchSelection = Set<UUID>()
    @State private var confirmBatchDelete = false
    @State private var unitToMove: ArmyUnit?
    @State private var showMoveUnit = false
    @State private var deleteWarningTrigger = false
    @State private var duplicateTrigger = false
    @State private var showMusterRoster = false

    @Query(sort: \Roster.sortIndex) private var rosters: [Roster]

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var overrides: [FactionPresetOverride] { cfg.factionOverrides }
    private var globalPipeline: [PipelineStage]? { cfg.globalPipeline }

    private var army: Army? { allArmies.first { $0.id == armyId } }

    private var visibleUnits: [ArmyUnit] {
        guard let army else { return [] }
        let vis = ArmyFilter.build(armies: [army], cfg: cfg, search: router.collectionSearch,
                                   global: globalPipeline)
        return vis.first?.units ?? army.orderedUnits
    }

    private var pipeline: [PipelineStage] {
        guard let army else { return Pipeline.resolve(globalPipeline) }
        return Pipeline.forArmy(army, global: globalPipeline)
    }

    private var usesSpearhead: Bool { visibleUnits.contains { $0.spearhead != nil } }
    private var percent: Int { Int((Pipeline.progress(of: visibleUnits, pipeline) * 100).rounded()) }
    private var usesPadSidebarList: Bool {
        AdaptiveLayout.usesSidebarListStyle(horizontalSizeClass, preferSelection: preferSidebarSelection)
    }

    private var selectedUnits: [ArmyUnit] {
        visibleUnits.filter { batchSelection.contains($0.id) }
    }

    private var otherArmies: [Army] {
        guard let army else { return [] }
        return allArmies.filter { $0.id != army.id }
    }

    private var showAdvanceTip: Bool {
        !isEditing && visibleUnits.contains { canAdvance($0) }
    }

    private var armyTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        horizontalSizeClass == .regular ? .inline : .large
    }

    var body: some View {
        Group {
            if let army {
                ArmyDetailUnitList(
                    army: army,
                    pres: army.presentation(overrides: overrides),
                    isEditing: isEditing,
                    percent: percent,
                    padSidebar: usesPadSidebarList,
                    visibleUnits: visibleUnits,
                    pipeline: pipeline,
                    showSpearhead: usesSpearhead,
                    showAdvanceTip: showAdvanceTip,
                    hasOtherArmies: !otherArmies.isEmpty,
                    batchSelection: $batchSelection,
                    selectedUnitId: $selectedUnitId,
                    canAdvance: canAdvance,
                    onSelectUnit: onSelectUnit,
                    onAddUnit: { showAddUnit = true },
                    onAdvance: advanceUnit,
                    onDuplicate: duplicateUnit,
                    onDelete: { unitToDelete = $0 },
                    onMove: beginMoveUnit
                )
            } else {
                ContentUnavailableView {
                    Label(String(localized: "Army not found"), systemImage: "shield")
                } description: {
                    Text(String(localized: "This army may have been deleted."))
                }
            }
        }
        .navigationTitle(army?.name ?? String(localized: "Army"))
        .navigationBarTitleDisplayMode(armyTitleDisplayMode)
        .toolbar { armyToolbar }
        .safeAreaInset(edge: .bottom) {
            ArmyDetailBatchActionBar(
                isEditing: isEditing,
                selectionCount: batchSelection.count,
                onAdvance: advanceBatchSelection,
                onDelete: { confirmBatchDelete = true }
            )
        }
        .sheet(isPresented: $showAddUnit) {
            if let army {
                AddUnitSheet(pipeline: pipeline) { name, qty, source, state, trackPerModel, memberStates in
                    ArmyStore.addUnit(
                        to: army, name: name, qty: qty, source: source, state: state,
                        trackPerModel: trackPerModel, memberStates: memberStates, in: context
                    )
                }
                .presentationDetents(AppInfo.isUITesting ? [.large] : [.medium, .large])
            }
        }
        .sheet(isPresented: $showRename) {
            if let army {
                RenameArmySheet(army: army, overrides: overrides, current: army.name) {
                    ArmyStore.rename(army, to: $0, in: context)
                }
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showPipeline) {
            if let army {
                ArmyPipelineEditorSheet(army: army, globalPipeline: globalPipeline, overrides: overrides)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showMoveUnit) {
            if let unit = unitToMove {
                MoveUnitSheet(
                    unitName: unit.name,
                    destinationArmies: otherArmies,
                    overrides: overrides
                ) { target in
                    _ = ArmyStore.move(unit, to: target, in: context)
                    if unit.id == selectedUnitId { selectedUnitId = nil }
                }
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showMusterRoster) {
            if let army {
                NewRosterSheet(prefillGame: army.game, prefillFaction: army.faction,
                               prefillLinkedArmyId: army.id)
            }
        }
        .confirmationDialog(
            String(localized: "Delete entire army \"\(army?.name ?? "")\" and all its units?"),
            isPresented: $confirmDeleteArmy,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                if let army {
                    if army.id == selectedArmyId { selectedArmyId = nil }
                    ArmyStore.delete(army, in: context)
                    dismiss()
                }
            }
        }
        .confirmationDialog(
            String(localized: "Remove \"\(unitToDelete?.name ?? "")\"?"),
            isPresented: Binding(get: { unitToDelete != nil }, set: { if !$0 { unitToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Remove"), role: .destructive) {
                if let unit = unitToDelete {
                    if unit.id == selectedUnitId { selectedUnitId = nil }
                    ArmyStore.delete(unit, in: context)
                    deleteWarningTrigger.toggle()
                }
                unitToDelete = nil
            }
            Button(String(localized: "Cancel"), role: .cancel) { unitToDelete = nil }
        }
        .confirmationDialog(
            String(localized: "Remove \(batchSelection.count) selected unit\(batchSelection.count == 1 ? "" : "s")?"),
            isPresented: $confirmBatchDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Remove"), role: .destructive) { deleteBatchSelection() }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
        .sensoryFeedback(.success, trigger: advanceTrigger)
        .sensoryFeedback(.warning, trigger: deleteWarningTrigger)
        .sensoryFeedback(.impact(weight: .light), trigger: duplicateTrigger)
        .onChange(of: isEditing) { _, editing in
            if editing {
                selectedUnitId = nil
            } else {
                batchSelection.removeAll()
            }
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }

    @ToolbarContentBuilder private var armyToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if isEditing {
                Button(String(localized: "Done")) { isEditing = false }
            } else {
                Button(String(localized: "Select")) { isEditing = true }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(String(localized: "Add unit"), systemImage: "plus") { showAddUnit = true }
                .accessibilityIdentifier("addUnit")
                .disabled(isEditing)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(String(localized: "Advance all"), systemImage: "arrow.right.to.line") {
                    if let army {
                        let n = ArmyStore.advanceAll(in: army, global: globalPipeline, in: context)
                        if n > 0 {
                            banner.show(String(localized: "Advanced \(n) unit\(n == 1 ? "" : "s")"))
                        } else {
                            banner.show(String(localized: "Nothing to advance"))
                        }
                        if n > 0 { advanceTrigger.toggle() }
                    }
                }
                Button(String(localized: "Merge duplicates"), systemImage: "square.on.square") {
                    if let army {
                        let n = ArmyStore.mergeDuplicates(in: army, ctx: context)
                        banner.show(n > 0
                            ? String(localized: "Merged \(n) duplicate\(n == 1 ? "" : "s")")
                            : String(localized: "No duplicates found"))
                    }
                }
                if ReleaseSurface.showsMusterTab {
                    Divider()
                    Button(String(localized: "Link army list…"), systemImage: "flag") {
                        if let army, let linked = linkedRoster(for: army) {
                            router.openMuster(rosterId: linked.id)
                        } else {
                            showMusterRoster = true
                        }
                    }
                }
                Button(String(localized: "Pipeline stages"), systemImage: "list.bullet") { showPipeline = true }
                Button(String(localized: "Reset crest & colour"), systemImage: "circle.lefthalf.filled") {
                    if let army { ArmyStore.resetTheme(army, in: context) }
                }
                Button(String(localized: "Rename"), systemImage: "pencil") { showRename = true }
                Button(String(localized: "Delete army"), systemImage: "trash", role: .destructive) { confirmDeleteArmy = true }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel(String(localized: "Army actions"))
            .disabled(isEditing)
        }
    }

    private func advanceUnit(_ unit: ArmyUnit) {
        ArmyStore.advance(unit, pipeline: pipeline, in: context)
        advanceTrigger.toggle()
        SwipeAdvanceTip().invalidate(reason: .actionPerformed)
    }

    private func advanceBatchSelection() {
        let n = ArmyStore.advance(selectedUnits, pipeline: pipeline, in: context)
        if n > 0 {
            banner.show(String(localized: "Advanced \(n) unit\(n == 1 ? "" : "s")"))
        } else {
            banner.show(String(localized: "Nothing to advance"))
        }
        if n > 0 { advanceTrigger.toggle() }
        batchSelection.removeAll()
    }

    private func beginMoveUnit(_ unit: ArmyUnit) {
        unitToMove = unit
        showMoveUnit = true
    }

    private func deleteBatchSelection() {
        let ids = batchSelection
        for unit in visibleUnits where ids.contains(unit.id) {
            if unit.id == selectedUnitId { selectedUnitId = nil }
            ArmyStore.delete(unit, in: context)
        }
        deleteWarningTrigger.toggle()
        batchSelection.removeAll()
        isEditing = false
    }

    private func canAdvance(_ unit: ArmyUnit) -> Bool { Pipeline.canAdvance(unit, pipeline) }

    private func duplicateUnit(_ unit: ArmyUnit) {
        guard let copy = ArmyStore.duplicate(unit, in: context) else { return }
        banner.show(String(localized: "Duplicated \(unit.name)"))
        duplicateTrigger.toggle()
        selectedUnitId = copy.id
        onSelectUnit(copy.id)
    }

    private func linkedRoster(for army: Army) -> Roster? {
        rosters.first { $0.linkedArmyId == army.id }
    }
}
