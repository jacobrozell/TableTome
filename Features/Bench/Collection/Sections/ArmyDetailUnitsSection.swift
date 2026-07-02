import SwiftUI
import TipKit
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailUnitsSection: View {
    let padSidebar: Bool
    let isEditing: Bool
    let visibleUnits: [ArmyUnit]
    let pipeline: [PipelineStage]
    let showSpearhead: Bool
    let showAdvanceTip: Bool
    let hasOtherArmies: Bool
    @Binding var selectedUnitId: UUID?
    let canAdvance: (ArmyUnit) -> Bool
    let onSelectUnit: (UUID) -> Void
    let onAddUnit: () -> Void
    let onAdvance: (ArmyUnit) -> Void
    let onDuplicate: (ArmyUnit) -> Void
    let onDelete: (ArmyUnit) -> Void
    let onMove: (ArmyUnit) -> Void

    var body: some View {
        Section {
            if visibleUnits.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: "No units yet"), systemImage: "figure.stand")
                } description: {
                    Text(String(localized: "Add what's on your sprue — name the unit and pick a starting state."))
                } actions: {
                    Button(String(localized: "Add unit"), systemImage: "plus") { onAddUnit() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("addUnit")
                }
                .listRowBackground(Color.clear)
                PipelineBeginnerLegend(pipeline: pipeline)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(visibleUnits) { unit in
                    let row = ArmyDetailUnitRow(
                        unit: unit,
                        pipeline: pipeline,
                        showSpearhead: showSpearhead,
                        isEditing: isEditing,
                        canAdvance: canAdvance(unit),
                        hasOtherArmies: hasOtherArmies,
                        onAdvance: { onAdvance(unit) },
                        onDuplicate: { onDuplicate(unit) },
                        onDelete: { onDelete(unit) },
                        onMove: { onMove(unit) }
                    )
                    Group {
                        if padSidebar {
                            Button {
                                selectedUnitId = unit.id
                                onSelectUnit(unit.id)
                            } label: { row }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("unit-\(unit.name)")
                        } else {
                            NavigationLink(value: CollectionRoute.unit(unit.id)) { row }
                                .navigationLinkIndicatorVisibility(.hidden)
                                .accessibilityIdentifier("unit-\(unit.name)")
                        }
                    }
                    .listSidebarSelection(isSelected: unit.id == selectedUnitId, enabled: padSidebar)
                }
            }
        } header: {
            Text(String(localized: "Units"))
                .popoverTip(showAdvanceTip ? SwipeAdvanceTip() : nil, arrowEdge: .top)
        }
    }
}
