import SwiftUI

public struct TTSegmentedControl<T: Hashable & Identifiable>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var selection: T
    private let options: [T]
    private let title: (T) -> String
    private let systemImage: ((T) -> String)?
    private let isDisabled: (T) -> Bool
    @Namespace private var selectionSpace

    public init(
        selection: Binding<T>,
        options: [T],
        title: @escaping (T) -> String,
        systemImage: ((T) -> String)? = nil,
        isDisabled: @escaping (T) -> Bool = { _ in false }
    ) {
        _selection = selection
        self.options = options
        self.title = title
        self.systemImage = systemImage
        self.isDisabled = isDisabled
    }

    public var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                ScrollView(.horizontal, showsIndicators: false) {
                    row
                }
            } else {
                row
                    .background(TTColor.sunken, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            }
        }
    }

    private var row: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    HStack(spacing: DesignTokens.Spacing.xxs) {
                        if let systemImage {
                            Image(systemName: systemImage(option))
                        }
                        Text(title(option))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .font(TTFont.buttonSmall)
                    .foregroundStyle(TTColor.inkPrimary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .frame(maxWidth: dynamicTypeSize.needsLayoutAdaptation ? nil : .infinity)
                    .frame(minHeight: 36)
                    .padding(.vertical, 4)
                    .background {
                        if option == selection, !dynamicTypeSize.needsLayoutAdaptation {
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous)
                                .fill(TTColor.raised)
                                .ttElevation(.card)
                                .matchedGeometryEffect(id: "segment", in: selectionSpace)
                        } else if option == selection {
                            Capsule().fill(TTColor.raised)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isDisabled(option))
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        }
        .padding(DesignTokens.Spacing.xxs)
        .animation(TTMotion.standard(reduceMotion: reduceMotion), value: selection)
    }
}
