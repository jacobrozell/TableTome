import SwiftUI

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
                .font(TTFont.numericMedium)
                .foregroundStyle(accent ? Color(hex: palette.gold) : TTColor.inkPrimary)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(TTColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: minTileHeight)
        .padding(.horizontal, DesignTokens.Spacing.xs)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(TTColor.raised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(TTColor.stroke, lineWidth: 1)
        }
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
