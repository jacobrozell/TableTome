import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Faction crest at a fixed size, keeping custom image support.
struct CrestTile: View {
    let text: String
    let colorHex: String
    var imageFileName: String? = nil
    var side: CGFloat = 44

    var body: some View {
        CrestBadge(text: text, colorHex: colorHex, imageFileName: imageFileName)
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                    .strokeBorder(TTColor.stroke, lineWidth: 1)
            }
    }
}

/// Browse row for one army in the collection list.
struct ArmyRow: View {
    let army: Army
    let overrides: [FactionPresetOverride]
    let visibleUnitCount: Int
    let percentComplete: Int
    let segments: [ProgressSegment]
    let scoped: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var presentation: FactionPresentation {
        army.presentation(overrides: overrides)
    }

    /// Stack crest above text in the iPad sidebar column or at large Dynamic Type.
    private var usesStackedLayout: Bool {
        dynamicTypeSize.needsLayoutAdaptation || AdaptiveLayout.usesSidebarListStyle(horizontalSizeClass)
    }

    private var hasCustomPipeline: Bool {
        army.customPipeline?.isEmpty == false
    }

    var body: some View {
        Group {
            if usesStackedLayout {
                stackedRow
            } else {
                horizontalRow
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                localized: "\(army.name), \(army.faction), \(percentComplete) percent complete, \(visibleUnitCount) units"
            )
        )
        .accessibilityHint(String(localized: "Opens army details"))
    }

    private var horizontalRow: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            crest
            textBlock
            disclosure
        }
    }

    private var stackedRow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                crest
                Spacer(minLength: 0)
                disclosure
            }
            textBlock
        }
    }

    private var crest: some View {
        CrestTile(
            text: presentation.crest,
            colorHex: presentation.colorHex,
            imageFileName: presentation.imageFileName,
            side: 44
        )
    }

    private var disclosure: some View {
        Image(systemName: "chevron.right")
            .font(TTFont.caption)
            .foregroundStyle(TTColor.inkTertiary)
            .accessibilityHidden(true)
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(army.name)
                .font(TTFont.headline)
                .foregroundStyle(TTColor.inkPrimary)
                .lineLimit(dynamicTypeSize.needsLayoutAdaptation ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
            Text(countLabel)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
            if hasCustomPipeline {
                TTBadge(String(localized: "Custom stages"))
            }
            HStack(spacing: DesignTokens.Spacing.sm) {
                ProgressMeter(segments: segments, height: 6)
                    .frame(maxWidth: .infinity)
                Text("\(percentComplete)%")
                    .font(TTFont.numericSmall)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var countLabel: String {
        scoped
            ? String(localized: "\(visibleUnitCount) visible")
            : String(localized: "\(visibleUnitCount) units")
    }
}
