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

/// Footnote and badges explaining where list points come from (GW catalog vs user override).
struct PointsSourceViews {
    enum PointsCapsuleStyle {
        case accent
        case custom
        case subtle
    }

    static func catalogAttributionLine(_ attribution: RosterCatalogSync.CatalogAttribution) -> String {
        if attribution.pointsKey.isEmpty {
            return String(localized: "Bundled catalog \(attribution.version)")
        }
        return String(
            localized: "Games Workshop Munitorum Field Manual (\(attribution.pointsKey)), catalog \(attribution.version)"
        )
    }

    @ViewBuilder
    static func catalogAttributionFootnote(
        _ attribution: RosterCatalogSync.CatalogAttribution,
        customOverrideCount: Int = 0
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "books.vertical")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
                Text(catalogAttributionLine(attribution))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if customOverrideCount > 0 {
                HStack(spacing: 6) {
                    customPointsBadge(compact: true)
                    Text(
                        String(
                            localized: """
                            \(customOverrideCount) unit\(customOverrideCount == 1 ? "" : "s") won't change when you \
                            update from catalog.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    static func pointsCapsule(_ text: String, style: PointsCapsuleStyle = .accent) -> some View {
        let tint: Color = switch style {
        case .accent: Color.accentColor
        case .custom: .orange
        case .subtle: .secondary
        }
        let foreground: Color = switch style {
        case .accent: Color.accentOnSurface
        case .custom: .orange
        case .subtle: .secondary
        }
        Text(text)
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(style == .subtle ? 0 : 0.12), in: Capsule())
    }

    @ViewBuilder
    static func entrySourceCallout(_ info: RosterCatalogSync.EntryPointsInfo) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: entrySourceSymbol(info.kind))
                .font(.caption.weight(.semibold))
                .foregroundStyle(entrySourceTint(info.kind))
                .symbolRenderingMode(.hierarchical)
                .frame(width: 16)
                .accessibilityHidden(true)
            entrySourceCaption(info)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    static func entrySourceCaption(_ info: RosterCatalogSync.EntryPointsInfo) -> some View {
        switch info.kind {
        case .catalog:
            if let catalogPts = info.catalogPoints, !info.pointsKey.isEmpty {
                Text(String(localized: "From GW Munitorum (\(info.pointsKey)): \(catalogPts) pts each"))
            } else if let catalogPts = info.catalogPoints {
                Text(String(localized: "From bundled catalog: \(catalogPts) pts each"))
            }
        case .customOverride:
            if let catalogPts = info.catalogPoints {
                Text(
                    String(
                        localized: "Custom value (catalog: \(catalogPts) pts from MFM \(info.pointsKey))"
                    )
                )
            } else {
                Text(String(localized: "Custom value — not in bundled catalog"))
            }
        case .catalogMissing:
            Text(String(localized: "Unit not in bundled catalog — enter points manually"))
        }
    }

    @ViewBuilder
    static func customPointsBadge(compact: Bool = false) -> some View {
        HStack(spacing: 4) {
            if !compact {
                Image(systemName: "pencil.line")
                    .font(.caption2.weight(.semibold))
                    .accessibilityHidden(true)
            }
            Text(String(localized: "Custom"))
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, compact ? 6 : 7)
        .padding(.vertical, 2)
        .background(Color.orange.opacity(0.18), in: Capsule())
        .foregroundStyle(.orange)
        .accessibilityLabel(String(localized: "Custom points"))
    }

    private static func entrySourceSymbol(_ kind: RosterCatalogSync.EntryPointsKind) -> String {
        switch kind {
        case .catalog: "book.closed"
        case .customOverride: "pencil.line"
        case .catalogMissing: "questionmark.circle"
        }
    }

    private static func entrySourceTint(_ kind: RosterCatalogSync.EntryPointsKind) -> Color {
        switch kind {
        case .catalog: Color.accentOnSurface
        case .customOverride: .orange
        case .catalogMissing: .secondary
        }
    }
}

/// SF Symbol for a bundled catalog unit category (Characters, Infantry, etc.).
enum CatalogCategorySymbol {
    static func systemImage(for category: String) -> String {
        switch category.lowercased() {
        case "character", "characters":
            "person.fill"
        case "infantry", "battleline":
            "figure.stand"
        case "vehicle", "vehicles":
            "car.fill"
        case "monster", "monsters", "beast", "beasts":
            "pawprint.fill"
        case "mounted":
            "figure.equestrian.sports"
        case "fortification", "fortifications":
            "building.columns.fill"
        default:
            "square.grid.2x2"
        }
    }
}

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
