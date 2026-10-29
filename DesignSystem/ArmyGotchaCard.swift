import SwiftUI
import TabletomeDomain

struct ArmyGotchaCard: View {
    let gotcha: SpearheadGotcha
    @State private var isExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: gotcha.systemImage)
                        .foregroundStyle(TTColor.warning)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(gotcha.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(gotcha.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(gotcha.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 28)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TTColor.warningSoft, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(TTColor.warningSoft, lineWidth: 0.5)
        )
        .accessibilityIdentifier("battleTracker.gotcha.\(gotcha.id)")
    }
}
