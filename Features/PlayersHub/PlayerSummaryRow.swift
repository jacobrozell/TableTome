import SwiftUI
import TabletomeDomain

/// Shared player identity row — Players Hub list, Guided Match army slots, pickers.
struct PlayerSummaryRow: View {
    let profile: PlayerProfile?
    let displayName: String
    var accentColorName: String?
    var isPrimary: Bool = false
    var ownedArmyCount: Int?
    var stats: PlayerMatchStats?
    var showsChevron: Bool = false
    var avatarSize: CGFloat = 48

    init(
        profile: PlayerProfile,
        isPrimary: Bool = false,
        stats: PlayerMatchStats? = nil,
        showsChevron: Bool = false,
        avatarSize: CGFloat = 48
    ) {
        self.profile = profile
        self.displayName = profile.displayName
        self.accentColorName = profile.accentColorName
        self.isPrimary = isPrimary
        self.ownedArmyCount = profile.ownedSpearheadArmyIds.count
        self.stats = stats
        self.showsChevron = showsChevron
        self.avatarSize = avatarSize
    }

    init(
        displayName: String,
        accentColorName: String? = nil,
        isPrimary: Bool = false,
        ownedArmyCount: Int? = nil,
        stats: PlayerMatchStats? = nil,
        showsChevron: Bool = false,
        avatarSize: CGFloat = 48
    ) {
        self.profile = nil
        self.displayName = displayName
        self.accentColorName = accentColorName
        self.isPrimary = isPrimary
        self.ownedArmyCount = ownedArmyCount
        self.stats = stats
        self.showsChevron = showsChevron
        self.avatarSize = avatarSize
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            PlayerAvatarView(
                name: displayName,
                accentColorName: accentColorName ?? profile?.accentColorName,
                size: avatarSize
            )

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if isPrimary {
                        PlayerBadge(title: String(localized: "Me"), style: .accent)
                    }
                    if let profile, profile.guidedMatchPreferences.experienceLevel == .tableRegular {
                        PlayerBadge(title: String(localized: "Regular"), style: .neutral)
                    }
                }

                if let subtitle = metadataSubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let stats, stats.gamesPlayed > 0 {
                    Text(stats.recordLabel)
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(Color.accentOnSurface)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 3)
                        .background(
                            Color.accentColor.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.nested, style: .continuous)
                        )
                }
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var metadataSubtitle: String? {
        var parts: [String] = []
        if let ownedArmyCount {
            let armyLabel = ownedArmyCount == 1
                ? String(localized: "1 army")
                : String(localized: "\(ownedArmyCount) armies")
            parts.append(armyLabel)
        }
        if let stats, let opponent = stats.lastOpponentName, stats.gamesPlayed > 0 {
            parts.append(String(localized: "last vs \(opponent)"))
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

struct PlayerBadge: View {
    enum Style {
        case accent
        case neutral
    }

    let title: String
    let style: Style

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 2)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.nested, style: .continuous))
            .foregroundStyle(foregroundColor)
    }

    private var backgroundColor: Color {
        switch style {
        case .accent: Color.accentColor.opacity(0.15)
        case .neutral: Color(.tertiarySystemFill)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .accent: Color.accentOnSurface
        case .neutral: Color.secondary
        }
    }
}
