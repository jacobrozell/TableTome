import SwiftUI

private struct SurfaceCardModifier: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 0.5)
            )
    }
}

public extension View {
    /// Groups content in the standard raised surface used across tracker and setup cards.
    func surfaceCard(padding: CGFloat = DesignTokens.Spacing.md) -> some View {
        modifier(SurfaceCardModifier(padding: padding))
    }

    /// Soft accent-tinted card used on Play home banners and new-player guidance.
    func accentHighlightCard(radius: CGFloat = DesignTokens.Radius.md) -> some View {
        padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
            }
    }
}

struct ProgressBadge: View {
    let done: Int
    let total: Int

    private var isComplete: Bool { total > 0 && done >= total }

    var body: some View {
        Text("\(done)/\(total)")
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 3)
            .background(
                isComplete ? Color.green.opacity(0.15) : Color(.tertiarySystemFill),
                in: Capsule()
            )
            .foregroundStyle(isComplete ? Color.green : Color.secondary)
    }
}

struct SectionHeader: View {
    let title: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

struct IntroCallout: View {
    let text: String
    var systemImage: String = "info.circle"

    var body: some View {
        Label {
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
        }
        .surfaceCard()
    }
}

struct DamageSummaryCard: View {
    let damage: Int
    var accessibilityId: String = "damageSummary"

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: damage > 0 ? "bolt.fill" : "shield.fill")
                .foregroundStyle(damage > 0 ? .orange : .green)
                .accessibilityHidden(true)
            Text(
                damage > 0
                    ? String(localized: "Damage to allocate")
                    : String(localized: "No damage dealt")
            )
            .font(.headline)
            Spacer()
            if damage > 0 {
                Text("\(damage)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(.orange)
                    .contentTransition(.numericText())
            }
        }
        .surfaceCard()
        .accessibilityLabel(
            damage > 0
                ? String(localized: "\(damage) damage to allocate")
                : String(localized: "No damage dealt")
        )
        .accessibilityIdentifier(accessibilityId)
    }
}

struct ReferenceLinkRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .frame(minHeight: DesignTokens.minTouchTarget)
    }
}

struct ReferenceLinksGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .surfaceCard(padding: 0)
    }
}

struct MatchupVersusBadge: View {
    var body: some View {
        Text(String(localized: "VS"))
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(Color(.tertiarySystemFill), in: Capsule())
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

struct TipsCard: View {
    let tips: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: String(localized: "Tips"), systemImage: "lightbulb.fill")
            ForEach(tips, id: \.self) { tip in
                Text(tip)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.07), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.yellow.opacity(0.25), lineWidth: 0.5)
        )
    }
}
