import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

/// State picker tinted to the current stage colour. Mirrors `.state-sel`.
struct StateMenu: View {
    let state: String
    let pipeline: [PipelineStage]
    let onSelect: (String) -> Void

    private var hex: String { pipeline.first { $0.key == state }?.hex ?? "#888" }

    var body: some View {
        Menu {
            ForEach(pipeline) { stage in
                Button {
                    onSelect(stage.key)
                } label: {
                    if stage.key == state { Label(stage.key, systemImage: "checkmark") }
                    else { Text(stage.key) }
                }
            }
        } label: {
            Text(state.isEmpty ? "—" : state)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .foregroundStyle(Color(hex: hex))
                .background(Color(hex: hex).opacity(0.12), in: Capsule())
                .overlay(Capsule().stroke(Color(hex: hex).opacity(0.5)))
        }
        .accessibilityLabel("Painting state")
        .accessibilityValue(state)
    }
}
