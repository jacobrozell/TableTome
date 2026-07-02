import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailBrowseModeList: View {
    let army: Army
    let pres: FactionPresentation
    let percent: Int
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
        List {
            ArmyDetailHeaderSection(
                army: army,
                pres: pres,
                percent: percent,
                visibleUnits: visibleUnits,
                pipeline: pipeline
            )
            ArmyDetailUnitsSection(
                padSidebar: padSidebar,
                isEditing: isEditing,
                visibleUnits: visibleUnits,
                pipeline: pipeline,
                showSpearhead: showSpearhead,
                showAdvanceTip: showAdvanceTip,
                hasOtherArmies: hasOtherArmies,
                selectedUnitId: $selectedUnitId,
                canAdvance: canAdvance,
                onSelectUnit: onSelectUnit,
                onAddUnit: onAddUnit,
                onAdvance: onAdvance,
                onDuplicate: onDuplicate,
                onDelete: onDelete,
                onMove: onMove
            )
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
    }
}
