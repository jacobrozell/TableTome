import SwiftUI

/// Checklist row that stacks the action below the text at large Dynamic Type sizes.
struct ChecklistStepRow<Extra: View>: View {
    let isComplete: Bool
    let isFocused: Bool
    let title: String
    let detail: String
    var showsDetail: Bool = true
    let accessibilityIdentifier: String
    let doneAccessibilityIdentifier: String?
    let onDone: (() -> Void)?
    @ViewBuilder var extra: () -> Extra

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        isComplete: Bool,
        isFocused: Bool,
        title: String,
        detail: String,
        showsDetail: Bool = true,
        accessibilityIdentifier: String,
        doneAccessibilityIdentifier: String? = nil,
        onDone: (() -> Void)? = nil,
        @ViewBuilder extra: @escaping () -> Extra = { EmptyView() }
    ) {
        self.isComplete = isComplete
        self.isFocused = isFocused
        self.title = title
        self.detail = detail
        self.showsDetail = showsDetail
        self.accessibilityIdentifier = accessibilityIdentifier
        self.doneAccessibilityIdentifier = doneAccessibilityIdentifier
        self.onDone = onDone
        self.extra = extra
    }

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    labelContent
                    doneButton
                }
            } else {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    labelContent
                    doneButton
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .padding(.horizontal, isFocused ? DesignTokens.Spacing.xs : 0)
        .background(
            isFocused ? Color.accentColor.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
        )
        .minimumTouchTarget(alignment: .leading)
    }

    private var labelContent: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: statusIcon)
                .font(.body)
                .foregroundStyle(statusColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(isFocused ? .bold : .semibold))
                if showsDetail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    extra()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var doneButton: some View {
        if let onDone, !isComplete {
            Button(String(localized: "Done"), action: onDone)
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .adaptiveControlSize()
                .accessibilityLabel(String(localized: "Mark step done"))
                .frame(
                    maxWidth: dynamicTypeSize.needsLayoutAdaptation ? .infinity : nil,
                    alignment: dynamicTypeSize.needsLayoutAdaptation ? .leading : .trailing
                )
                .accessibilityIdentifier(doneAccessibilityIdentifier ?? accessibilityIdentifier)
        }
    }

    private var statusIcon: String {
        if isComplete { return "checkmark.circle.fill" }
        if isFocused { return "circle.inset.filled" }
        return "circle"
    }

    private var statusColor: Color {
        if isComplete { return .green }
        if isFocused { return Color.accentColor }
        return Color.secondary.opacity(0.5)
    }
}
