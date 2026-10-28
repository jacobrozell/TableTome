import SwiftUI

/// Shared continuous corner shape for `surfaceCard` and `accentHighlightCard`.
enum CardSurface {
    static func shape(radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

private struct SurfaceCardModifier: ViewModifier {
    var padding: CGFloat
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                CardSurface.shape(radius: radius)
                    .fill(TTColor.surface)
                CardSurface.shape(radius: radius)
                    .strokeBorder(TTColor.stroke, lineWidth: 1)
            }
            .clipShape(CardSurface.shape(radius: radius))
            .ttElevation(.card)
    }
}

public extension View {
    /// Groups content in the standard raised surface used across tracker and setup cards.
    func surfaceCard(
        padding: CGFloat = DesignTokens.Spacing.md,
        radius: CGFloat = DesignTokens.Radius.card
    ) -> some View {
        modifier(SurfaceCardModifier(padding: padding, radius: radius))
    }

    /// Inset panel inside a primary card — loadout options, realm side chips, phase hints.
    func nestedCard(padding: CGFloat = DesignTokens.Spacing.sm) -> some View {
        surfaceCard(padding: padding, radius: DesignTokens.Radius.nested)
    }

    /// Soft accent-tinted card used on Play home banners and new-player guidance.
    func accentHighlightCard(
        tone: TTTone = .brand,
        radius: CGFloat = DesignTokens.Radius.card
    ) -> some View {
        padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                CardSurface.shape(radius: radius)
                    .fill(tone.soft)
                CardSurface.shape(radius: radius)
                    .strokeBorder(tone.foreground.opacity(0.35), lineWidth: 1)
            }
            .clipShape(CardSurface.shape(radius: radius))
    }

    /// Neutral onboarding / picker row — same corners as cards, without accent tint.
    func onboardingPickerRow() -> some View {
        padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                CardSurface.shape(radius: DesignTokens.Radius.card)
                    .fill(TTColor.raised)
                CardSurface.shape(radius: DesignTokens.Radius.card)
                    .strokeBorder(TTColor.stroke, lineWidth: 1)
            }
            .clipShape(CardSurface.shape(radius: DesignTokens.Radius.card))
            .ttElevation(.card)
    }

    /// Embeds a self-drawn card in a `List` row without grouped-list corner clipping.
    func listHeroCardRow() -> some View {
        listRowInsets(
            EdgeInsets(
                top: DesignTokens.Spacing.sm,
                leading: 0,
                bottom: DesignTokens.Spacing.sm,
                trailing: 0
            )
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    /// Plain list with side margins so floating cards keep visible corners on every edge.
    func floatingCardListStyle() -> some View {
        listStyle(.plain)
            .contentMargins(.horizontal, DesignTokens.Spacing.md, for: .scrollContent)
            .contentMargins(.top, DesignTokens.Spacing.xs, for: .scrollContent)
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
                isComplete ? TTColor.successSoft : TTColor.sunken,
                in: Capsule()
            )
            .foregroundStyle(isComplete ? TTColor.success : TTColor.inkSecondary)
    }
}

struct SectionHeader: View {
    let title: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(TTColor.inkTertiary)
                    .accessibilityHidden(true)
            }
            Text(title)
                .ttEyebrow()
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
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(TTColor.brand)
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
                .foregroundStyle(damage > 0 ? TTColor.danger : TTColor.success)
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
                    .font(TTFont.numericLarge)
                    .foregroundStyle(TTColor.danger)
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
            Image(systemName: systemImage)
                .foregroundStyle(TTColor.brand)
                .accessibilityHidden(true)
            Text(title)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkPrimary)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkTertiary)
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
            .ttEyebrow()
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(TTColor.sunken, in: Capsule())
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

struct TipsCard: View {
    let tips: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(TTColor.warning)
                    .accessibilityHidden(true)
                SectionHeader(title: String(localized: "Tips"))
            }
            ForEach(tips, id: \.self) { tip in
                Text(tip)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            CardSurface.shape(radius: DesignTokens.Radius.card)
                .fill(TTTone.warning.soft)
            CardSurface.shape(radius: DesignTokens.Radius.card)
                .strokeBorder(TTColor.warning.opacity(0.35), lineWidth: 1)
        }
        .clipShape(CardSurface.shape(radius: DesignTokens.Radius.card))
    }
}
