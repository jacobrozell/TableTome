import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailUnitRow: View {
    let unit: ArmyUnit
    let pipeline: [PipelineStage]
    let showSpearhead: Bool
    let isEditing: Bool
    let canAdvance: Bool
    let hasOtherArmies: Bool
    let onAdvance: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onMove: () -> Void

    var body: some View {
        UnitRow(unit: unit, pipeline: pipeline, showSpearhead: showSpearhead)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if !isEditing, canAdvance {
                    Button(String(localized: "Advance")) {
                        onAdvance()
                    }
                    .tint(.accentColor)
                    .accessibilityLabel(String(localized: "Advance painting state"))
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if !isEditing {
                    Button(String(localized: "Duplicate")) { onDuplicate() }
                    .accessibilityLabel(String(localized: "Duplicate unit"))
                    Button(String(localized: "Delete"), role: .destructive) { onDelete() }
                        .accessibilityLabel(String(localized: "Delete unit"))
                }
            }
            .contextMenu {
                if !isEditing {
                    if canAdvance {
                        Button(String(localized: "Advance"), systemImage: "arrow.right.circle") {
                            onAdvance()
                        }
                    }
                    Button(String(localized: "Duplicate"), systemImage: "plus.square.on.square") { onDuplicate() }
                    if hasOtherArmies {
                        Button(String(localized: "Move to…"), systemImage: "arrow.right.arrow.left") {
                            onMove()
                        }
                    }
                    Button(String(localized: "Delete"), systemImage: "trash", role: .destructive) {
                        onDelete()
                    }
                }
            }
    }
}
