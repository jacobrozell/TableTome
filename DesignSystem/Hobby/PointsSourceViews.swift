import SwiftUI
import TabletomeDomain

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
