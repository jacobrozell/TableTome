import SwiftUI
import TabletomeHobbyData

/// Read-only paint row for list layout.
struct PaintRow: View {
    let paint: HobbyPaint
    let linkedCount: Int

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var usesStackedLayout: Bool {
        dynamicTypeSize.isAccessibilitySize || AdaptiveLayout.usesSidebarListStyle(horizontalSizeClass)
    }

    var body: some View {
        Group {
            if usesStackedLayout {
                stackedRow
            } else {
                horizontalRow
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [
            paint.name,
            paint.type,
            String(localized: "quantity \(paint.qty)")
        ]
        if paint.low { parts.append(String(localized: "running low")) }
        if linkedCount > 0 { parts.append(String(localized: "\(linkedCount) linked units")) }
        return parts.joined(separator: ", ")
    }

    private var swatch: some View {
        PaintSwatch(hex: paint.swatchHex)
            .fixedSize()
    }

    private var horizontalRow: some View {
        HStack(alignment: .center, spacing: 12) {
            swatch
            textBlock
            qtyLabel
        }
    }

    private var stackedRow: some View {
        HStack(alignment: .top, spacing: 12) {
            swatch
            VStack(alignment: .leading, spacing: 3) {
                textBlock
                qtyLabel
            }
        }
    }

    @ViewBuilder
    private var qtyLabel: some View {
        if paint.qty > 1 {
            Text("×\(paint.qty)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .fixedSize()
        }
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(paint.name)
                    .font(.headline)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                if paint.low {
                    Text(String(localized: "LOW"))
                        .font(.caption2.bold())
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(.orange.opacity(0.2), in: Capsule())
                        .fixedSize()
                }
            }
            let meta = [paint.type, paint.brand].filter { !$0.isEmpty }.joined(separator: " · ")
            if !meta.isEmpty {
                Text(meta)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            if !paint.source.isEmpty {
                Text(
                    linkedCount > 0
                        ? String(localized: "\(paint.source) (\(linkedCount) units)")
                        : paint.source
                )
                    .font(.caption2)
                    .foregroundStyle(.tint)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
