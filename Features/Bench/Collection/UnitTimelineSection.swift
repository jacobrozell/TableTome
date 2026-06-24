import SwiftUI
import TabletomeHobbyData
import TabletomeDomain
import SwiftData

/// Chronological painting progress for a unit (stage changes and future photo checkpoints).
struct UnitTimelineSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let unit: ArmyUnit
    let pipeline: [PipelineStage]

    private var events: [StageEvent] {
        unit.orderedStageEvents
    }

    var body: some View {
        Section {
            if events.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: "No progress yet"), systemImage: "clock.arrow.circlepath")
                } description: {
                    Text(
                        String(
                            localized: """
                            Advance painting stages or add photos to build a timeline for this unit.
                            """
                        )
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(events) { event in
                    timelineRow(event)
                }
            }
        } header: {
            Text(String(localized: "Timeline"))
        } footer: {
            if events.isEmpty {
                Text(
                    String(
                        localized: "Stage changes are recorded automatically when you advance or edit painting state."
                    )
                )
            } else if !unit.photos.isEmpty {
                Text(String(localized: "Photos from matching stages appear beside the closest event."))
            }
        }
    }

    @ViewBuilder
    private func timelineRow(_ event: StageEvent) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                timelineDetails(event)
                if let thumb = photoNear(event) {
                    UnitPhotoThumb(photo: thumb)
                }
            }
            .accessibilityElement(children: .combine)
        } else {
            HStack(alignment: .top, spacing: 10) {
                timelineDetails(event)
                Spacer(minLength: 0)
                if let thumb = photoNear(event) {
                    UnitPhotoThumb(photo: thumb)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private func timelineDetails(_ event: StageEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                StateChip(state: event.stageKey, pipeline: pipeline)
                if let index = event.memberIndex {
                    Text("#\(index + 1)")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            Text(event.occurredAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let previous = event.previousStageKey, previous != event.stageKey {
                Text(String(localized: "from \(previous)"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    /// Photo captured at the same stage, closest in time to the event (if any).
    private func photoNear(_ event: StageEvent) -> ModelPhoto? {
        let candidates = unit.orderedPhotos.filter {
            $0.stageKey == event.stageKey
            && (event.memberIndex == nil || $0.memberIndex == event.memberIndex)
        }
        return candidates.min {
            abs($0.createdAt.timeIntervalSince(event.occurredAt))
            < abs($1.createdAt.timeIntervalSince(event.occurredAt))
        }
    }
}
