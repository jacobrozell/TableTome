import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

/// Picker row label for a pipeline stage with colour dot.
struct PipelineStagePickerRow: View {
    let stage: PipelineStage

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: stage.hex))
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(stage.key)
        }
    }
}
