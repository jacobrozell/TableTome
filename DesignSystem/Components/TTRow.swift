import SwiftUI

public enum TTRowAccessory: Equatable {
    case chevron
    case none
    case check(Bool)
    case value(String)
    case external
}

public struct TTRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let tone: TTTone
    private let badge: TTBadge?
    private let accessory: TTRowAccessory

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        tone: TTTone = .brand,
        badge: TTBadge? = nil,
        accessory: TTRowAccessory = .chevron
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tone = tone
        self.badge = badge
        self.accessory = accessory
    }

    public var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    if let systemImage {
                        TTIconTile(systemImage: systemImage, tone: tone)
                    }
                    label
                    accessoryView
                }
            } else {
                HStack(spacing: 12) {
                    if let systemImage {
                        TTIconTile(systemImage: systemImage, tone: tone)
                    }
                    label
                    Spacer(minLength: DesignTokens.Spacing.sm)
                    accessoryView
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                if let badge { badge }
            }
            if let subtitle {
                Text(subtitle)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkSecondary)
                    .lineLimit(2)
            }
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right")
                .foregroundStyle(TTColor.inkTertiary)
                .accessibilityHidden(true)
        case .none:
            EmptyView()
        case .check(let on):
            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(on ? TTColor.brand : TTColor.inkTertiary)
                .accessibilityHidden(true)
        case .value(let value):
            Text(value)
                .font(TTFont.bodyEmphasis)
                .foregroundStyle(TTColor.inkPrimary)
        case .external:
            Image(systemName: "arrow.up.right")
                .foregroundStyle(TTColor.inkTertiary)
                .accessibilityHidden(true)
        }
    }
}

#Preview("TTRow") {
    TTPreviewMatrix {
        TTRow(title: "Spearhead", subtitle: "Your starter box", systemImage: "shield.lefthalf.filled")
    }
}
