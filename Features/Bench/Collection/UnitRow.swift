import SwiftUI
import TabletomeHobbyData
import TabletomeDomain
import SwiftData

/// Read-only unit summary for list rows (army detail).
struct UnitRow: View {
    let unit: ArmyUnit
    let pipeline: [PipelineStage]
    let showSpearhead: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var stacksStateChip: Bool { dynamicTypeSize.needsLayoutAdaptation }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            if let cover = unit.coverPhoto {
                UnitPhotoThumb(photo: cover)
            }
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                rowContent
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(String(localized: "Opens unit details"))
    }

    @ViewBuilder
    private var rowContent: some View {
        if stacksStateChip {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                nameText
                StageCapsule(state: unit.state, pipeline: pipeline)
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                nameText
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                StageCapsule(state: unit.state, pipeline: pipeline)
                    .fixedSize()
                    .layoutPriority(-1)
            }
        }
        HStack(spacing: DesignTokens.Spacing.xs) {
            if !unit.source.isEmpty {
                Text(unit.source)
            }
            if !unit.source.isEmpty {
                Text("·")
            }
            Text(modelLabel)
            if showSpearhead, unit.spearhead == true {
                Text("·")
                Image(systemName: "star.fill")
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.brand)
                    .accessibilityLabel(String(localized: "Spearhead"))
            }
        }
        .font(TTFont.caption)
        .foregroundStyle(TTColor.inkSecondary)
        .lineLimit(2)
        .truncationMode(.tail)
        if unit.hasSquadMembers {
            Text(Members.stateSummary(of: unit))
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkSecondary)
        }
    }

    private var nameText: some View {
        Text(unit.name)
            .font(TTFont.headline)
            .foregroundStyle(TTColor.inkPrimary)
            .lineLimit(stacksStateChip ? 3 : 2)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var modelLabel: String {
        "×\(unit.modelCount)"
    }

    private var spokenModelCount: String {
        unit.modelCount == 1
            ? String(localized: "1 model")
            : String(localized: "\(unit.modelCount) models")
    }

    private var accessibilityText: String {
        var parts = [unit.name, unit.state, spokenModelCount]
        if !unit.source.isEmpty { parts.append(unit.source) }
        if unit.spearhead == true { parts.append(String(localized: "spearhead")) }
        return parts.joined(separator: ", ")
    }
}

/// Stage capsule tinted with the stage colour at 14% fill.
struct StageCapsule: View {
    let state: String
    let pipeline: [PipelineStage]

    private var hex: String? {
        pipeline.first { $0.key == state }?.hex
    }

    private var label: String {
        state.isEmpty ? "—" : state
    }

    var body: some View {
        Text(label)
            .font(TTFont.caption.weight(.semibold))
            .foregroundStyle(hex.map { Color(hex: $0) } ?? TTColor.inkSecondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 3)
            .background(fill, in: Capsule())
            .accessibilityLabel(String(localized: "Painting state \(label)"))
    }

    private var fill: Color {
        if let hex {
            return Color(hex: hex).opacity(0.14)
        }
        return TTColor.sunken
    }
}
