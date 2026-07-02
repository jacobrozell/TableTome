import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

/// Compact painting-stage path for empty army detail — key milestones only.
struct PipelineBeginnerLegend: View {
    let pipeline: [PipelineStage]

    private var milestoneKeys: [String] {
        ["Unassembled", "Assembled", "Primed", "Done"]
    }

    private var milestones: [PipelineStage] {
        milestoneKeys.compactMap { key in pipeline.first { $0.key == key } }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Painting stages"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(milestones.enumerated()), id: \.element.id) { index, stage in
                        if index > 0 {
                            Image(systemName: "arrow.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.tertiary)
                                .accessibilityHidden(true)
                        }
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: stage.hex))
                                .frame(width: 8, height: 8)
                                .accessibilityHidden(true)
                            Text(stage.key)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Text(FormHints.pipelineBeginner)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
