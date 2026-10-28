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
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        timelineRow(event, isLast: index == events.count - 1)
                    }
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
        .listRowBackground(TTColor.surface)
    }

    @ViewBuilder
    private func timelineRow(_ event: StageEvent, isLast: Bool) -> some View {
        let hex = pipeline.first { $0.key == event.stageKey }?.hex ?? ""
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            timelineIcon(hex: hex)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        timelineDetails(event)
                        if let thumb = photoNear(event) {
                            UnitPhotoThumb(photo: thumb)
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        timelineDetails(event)
                        Spacer(minLength: 0)
                        if let thumb = photoNear(event) {
                            UnitPhotoThumb(photo: thumb)
                        }
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : DesignTokens.Spacing.md)
        }
        .background(alignment: .topLeading) {
            if !isLast {
                Rectangle()
                    .fill(TTColor.stroke)
                    .frame(width: 2)
                    .padding(.leading, 13)
                    .padding(.top, 28)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func timelineIcon(hex: String) -> some View {
        Circle()
            .fill(hex.isEmpty ? TTColor.sunken : Color(hex: hex))
            .frame(width: 28, height: 28)
            .overlay {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(TTFont.caption)
                    .foregroundStyle(hex.isEmpty ? TTColor.inkSecondary : Color(hex: hex).legibleForeground)
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func timelineDetails(_ event: StageEvent) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(event.stageKey.isEmpty ? "—" : event.stageKey)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkPrimary)
                if let index = event.memberIndex {
                    Text("#\(index + 1)")
                        .font(TTFont.caption)
                        .foregroundStyle(TTColor.inkTertiary)
                }
            }
            Text(event.occurredAt.formatted(date: .abbreviated, time: .shortened))
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkTertiary)
            if let previous = event.previousStageKey, previous != event.stageKey {
                Text(String(localized: "from \(previous)"))
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkTertiary)
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
