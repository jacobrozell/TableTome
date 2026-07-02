import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailEditModeList: View {
    let army: Army
    let pres: FactionPresentation
    let percent: Int
    let visibleUnits: [ArmyUnit]
    let pipeline: [PipelineStage]
    let showSpearhead: Bool
    let hasOtherArmies: Bool
    @Binding var batchSelection: Set<UUID>
    let canAdvance: (ArmyUnit) -> Bool
    let onAdvance: (ArmyUnit) -> Void
    let onDuplicate: (ArmyUnit) -> Void
    let onDelete: (ArmyUnit) -> Void
    let onMove: (ArmyUnit) -> Void

    var body: some View {
        List(selection: $batchSelection) {
            ArmyDetailHeaderSection(
                army: army,
                pres: pres,
                percent: percent,
                visibleUnits: visibleUnits,
                pipeline: pipeline
            )
            Section(String(localized: "Units")) {
                if visibleUnits.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No units"), systemImage: "figure.stand")
                    } description: {
                        Text(String(localized: "Add a unit or adjust filters."))
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(visibleUnits) { unit in
                        ArmyDetailUnitRow(
                            unit: unit,
                            pipeline: pipeline,
                            showSpearhead: showSpearhead,
                            isEditing: true,
                            canAdvance: canAdvance(unit),
                            hasOtherArmies: hasOtherArmies,
                            onAdvance: { onAdvance(unit) },
                            onDuplicate: { onDuplicate(unit) },
                            onDelete: { onDelete(unit) },
                            onMove: { onMove(unit) }
                        )
                        .tag(unit.id)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
    }
}
