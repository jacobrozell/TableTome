import SwiftUI

public struct TTStat: Equatable, Identifiable {
    public let id: String
    public let label: String
    public let value: String
    public var isModified: Bool

    public init(label: String, value: String, isModified: Bool = false) {
        self.id = label
        self.label = label
        self.value = value
        self.isModified = isModified
    }
}

public struct TTStatStrip: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let stats: [TTStat]

    public init(stats: [TTStat]) {
        self.stats = stats
    }

    public var body: some View {
        let columns = dynamicTypeSize.needsLayoutAdaptation ? 2 : min(4, max(stats.count, 1))
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.xs), count: columns), spacing: DesignTokens.Spacing.xs) {
            ForEach(stats) { stat in
                VStack(spacing: DesignTokens.Spacing.xxs) {
                    HStack(spacing: 2) {
                        Text(stat.value)
                            .font(TTFont.numericMedium)
                            .foregroundStyle(stat.isModified ? TTColor.brand : TTColor.inkPrimary)
                        if stat.isModified {
                            Text("*")
                                .font(TTFont.caption)
                                .foregroundStyle(TTColor.brand)
                        }
                    }
                    Text(stat.label)
                        .font(TTFont.caption)
                        .textCase(.uppercase)
                        .foregroundStyle(TTColor.inkSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(TTColor.sunken, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.xs, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(stat.label) \(stat.value)")
            }
        }
    }
}

#Preview("TTStatStrip") {
    TTPreviewMatrix {
        TTStatStrip(stats: [
            TTStat(label: "Move", value: "5\""),
            TTStat(label: "Save", value: "4+"),
            TTStat(label: "Health", value: "5"),
            TTStat(label: "Control", value: "1")
        ])
    }
}
