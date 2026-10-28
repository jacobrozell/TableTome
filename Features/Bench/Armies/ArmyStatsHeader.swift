import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Collection stats tiles + overall progress meter. Mirrors `renderArmyStats`.
/// `units`/`armyCount` are the scoped set when filters are active; `scoped` adds the
/// "(filtered)" labels.
struct ArmyStatsHeader: View {
    let units: [ArmyUnit]
    let armyCount: Int
    let pipeline: [PipelineStage]
    var scoped: Bool = false
    var showsProgress: Bool = true

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var statColumns: [GridItem] {
        if dynamicTypeSize >= .accessibility5 {
            return [GridItem(.flexible())]
        }
        if dynamicTypeSize.needsLayoutAdaptation {
            return [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.sm)
            ]
        }
        let count = horizontalSizeClass == .regular ? 4 : 3
        return Array(
            repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.sm),
            count: count
        )
    }

    private func label(_ base: String) -> String {
        scoped ? String(localized: "\(base) (filtered)") : base
    }

    var body: some View {
        let stats = CollectionStats.snapshot(units: units, pipeline: pipeline)

        VStack(spacing: DesignTokens.Spacing.sm) {
            LazyVGrid(columns: statColumns, spacing: DesignTokens.Spacing.sm) {
                StatTile(value: stats.unitEntries, label: label(String(localized: "Unit entries")))
                StatTile(value: stats.models, label: label(String(localized: "Models (est.)")), accent: true)
                StatTile(value: stats.based, label: label(CollectionStats.basedStage(in: pipeline)?.key ?? String(localized: "Based")))
                StatTile(value: stats.done, label: label(CollectionStats.doneStage(in: pipeline)?.key ?? String(localized: "Done")))
                StatTile(value: stats.wip, label: String(localized: "In Progress"))
                StatTile(value: stats.todo, label: String(localized: "Unassembled"))
                StatTile(value: armyCount, label: label(String(localized: "Armies")))
            }

            if showsProgress {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(
                            scoped
                                ? String(localized: "Filtered progress (by model count)")
                                : String(localized: "Collection progress (by model count)")
                        )
                            .font(TTFont.caption)
                            .foregroundStyle(TTColor.inkSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: DesignTokens.Spacing.sm)
                        Text("\(stats.overallPercent)%")
                            .font(TTFont.numericSmall)
                            .foregroundStyle(TTColor.inkPrimary)
                            .fixedSize()
                    }
                    ProgressMeter(segments: stats.segments, height: 10)
                    ProgressLegend(segments: stats.segments)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized: "Collection progress \(stats.overallPercent) percent"))
            }
        }
    }
}

/// Wrapping legend of swatch + stage name under the collection meter.
struct ProgressLegend: View {
    let segments: [ProgressSegment]

    var body: some View {
        if !segments.isEmpty {
            FlowText(segments: segments)
        }
    }
}

/// Simple wrapping row of legend chips.
private struct FlowText: View {
    let segments: [ProgressSegment]
    var body: some View {
        ViewThatFits(in: .horizontal) {
            row
            ScrollView(.horizontal, showsIndicators: false) { row }
        }
    }
    private var row: some View {
        HStack(spacing: 10) {
            ForEach(segments) { seg in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2).fill(Color(hex: seg.hex)).frame(width: 8, height: 8)
                    Text(seg.key).font(.caption2).foregroundStyle(TTColor.inkSecondary)
                }
            }
        }
    }
}
