import SwiftUI
import Foundation
import TabletomeHobbyData
import TabletomeDomain

/// Stacked progress meter. Renders `Pipeline.segments` as width-proportional colour bars.
/// Mirrors the web `.meter` / `.army-bar` (`docs/ios-spec/10 §4`).
struct ProgressMeter: View {
    let segments: [ProgressSegment]
    var height: CGFloat = 10

    @ScaledMetric(relativeTo: .caption) private var scaledHeight: CGFloat = 10

    private var barHeight: CGFloat { height == 10 ? scaledHeight : height }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                if segments.isEmpty {
                    Rectangle().fill(.quaternary)
                } else {
                    ForEach(segments) { seg in
                        Rectangle()
                            .fill(Color(hex: seg.hex))
                            .frame(width: max(0, geo.size.width * seg.pct / 100))
                    }
                }
            }
        }
        .frame(height: barHeight)
        .clipShape(Capsule())
        .accessibilityHidden(true)
    }
}

/// Faction crest badge: abbreviation on the accent colour. Mirrors `.crest`.
struct CrestBadge: View {
    let text: String
    let colorHex: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Text(text)
            .font(.system(.caption, design: .serif).weight(.bold))
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
            .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .frame(minWidth: 44, minHeight: 30)
            .background(Color(hex: colorHex), in: RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(Color(hex: colorHex).legibleForeground)
            .accessibilityLabel("Faction crest \(text)")
    }
}

/// A single stat tile: big serif value over a condensed label. Mirrors `.tile`.
struct StatTile: View {
    let value: Int
    let label: String
    var accent: Bool = false

    @Environment(\.palette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var minTileHeight: CGFloat {
        dynamicTypeSize.needsLayoutAdaptation ? 88 : 72
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(accent ? Color(hex: palette.gold) : .primary)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: minTileHeight)
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        if label == String(localized: "Unassembled") {
            return String(localized: "Unassembled models, on the sprue, \(value)")
        }
        return "\(label), \(value)"
    }
}

/// Small paint colour swatch for list and detail rows.
struct PaintSwatch: View {
    let hex: String
    var size: CGFloat = 28
    var cornerRadius: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(hex: hex))
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.55), lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}

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

extension Color {
    /// Black or white, whichever reads better on this colour (WCAG-ish luminance).
    var legibleForeground: Color {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        func lin(_ c: CGFloat) -> CGFloat { c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        let l = 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
        return l > 0.4 ? .black : .white
    }
}
