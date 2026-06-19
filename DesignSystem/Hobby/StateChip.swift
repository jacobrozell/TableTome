import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Read-only painting-state capsule for browse rows.
struct StateChip: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: String
    let pipeline: [PipelineStage]
    var inherited: Bool = false

    private var hex: String { pipeline.first { $0.key == state }?.hex ?? "#888" }

    var body: some View {
        Text(state.isEmpty ? "—" : state)
            .font(.caption.weight(.semibold))
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
            .padding(.horizontal, 8).padding(.vertical, 5)
            .foregroundStyle(Color(hex: hex))
            .background(Color(hex: hex).opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(Color(hex: hex).opacity(0.5)))
            .accessibilityLabel(inherited ? "Painting state \(state), inherited" : "Painting state \(state)")
    }
}
