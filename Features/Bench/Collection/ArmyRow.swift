import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Browse row for one army in the collection list.
struct ArmyRow: View {
    let army: Army
    let overrides: [FactionPresetOverride]
    let visibleUnitCount: Int
    let percentComplete: Int
    let scoped: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var presentation: (crest: String, colorHex: String) {
        army.presentation(overrides: overrides)
    }

    /// Stack crest/progress above text when the sidebar is narrow or text is large.
    private var usesStackedLayout: Bool {
        dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .regular
    }

    var body: some View {
        Group {
            if usesStackedLayout {
                stackedRow
            } else {
                horizontalRow
            }
        }
        .padding(.vertical, 4)
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
        HStack(alignment: .center, spacing: 12) {
            crest
            textBlock
            ProgressRing(percent: percentComplete, diameter: 32)
        }
    }

    private var stackedRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                crest
                Spacer(minLength: 0)
                ProgressRing(percent: percentComplete, diameter: 32)
            }
            textBlock
        }
    }

    private var crest: some View {
        CrestBadge(text: presentation.crest, colorHex: presentation.colorHex)
            .fixedSize()
    }

    private var textBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(army.name)
                .font(.headline)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
            metadataBlock
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var metadataBlock: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(army.game) · \(army.faction)")
                Text(countLabel)
                if army.customPipeline?.isEmpty == false {
                    Text(String(localized: "custom pipeline"))
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var countLabel: String {
        scoped
            ? String(localized: "\(visibleUnitCount) visible")
            : String(localized: "\(visibleUnitCount) units")
    }

    private var subtitle: String {
        var parts = [army.game, army.faction, countLabel]
        if army.customPipeline?.isEmpty == false {
            parts.append(String(localized: "custom pipeline"))
        }
        return parts.joined(separator: " · ")
    }
}
