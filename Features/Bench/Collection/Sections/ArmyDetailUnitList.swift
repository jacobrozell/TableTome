import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailUnitList: View {
    let army: Army
    let pres: FactionPresentation
    let isEditing: Bool
    let percent: Int
    let padSidebar: Bool
    let visibleUnits: [ArmyUnit]
    let pipeline: [PipelineStage]
    let showSpearhead: Bool
    let showAdvanceTip: Bool
    let hasOtherArmies: Bool
    @Binding var batchSelection: Set<UUID>
    @Binding var selectedUnitId: UUID?
    let canAdvance: (ArmyUnit) -> Bool
    let onSelectUnit: (UUID) -> Void
    let onAddUnit: () -> Void
    let onAdvance: (ArmyUnit) -> Void
    let onDuplicate: (ArmyUnit) -> Void
    let onDelete: (ArmyUnit) -> Void
    let onMove: (ArmyUnit) -> Void

    var body: some View {
        if isEditing {
            ArmyDetailEditModeList(
                army: army,
                pres: pres,
                percent: percent,
                visibleUnits: visibleUnits,
                pipeline: pipeline,
                showSpearhead: showSpearhead,
                hasOtherArmies: hasOtherArmies,
                batchSelection: $batchSelection,
                canAdvance: canAdvance,
                onAdvance: onAdvance,
                onDuplicate: onDuplicate,
                onDelete: onDelete,
                onMove: onMove
            )
        } else {
            ArmyDetailBrowseModeList(
                army: army,
                pres: pres,
                percent: percent,
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
    }
}
