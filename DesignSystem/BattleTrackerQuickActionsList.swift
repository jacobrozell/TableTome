import SwiftUI
import TabletomeDomain

struct BattleTrackerQuickActionsList: View {
    let actions: [BattleTrackerQuickAction]
    let onSelect: (BattleTrackerQuickAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What's next"), systemImage: "list.bullet")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(actions) { action in
                    Button {
                        onSelect(action)
                    } label: {
                        quickActionRow(action)
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.quickAction.\(action.id)")
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.quickActions")
    }

    private func quickActionRow(_ action: BattleTrackerQuickAction) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: action.systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                if let detail = action.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BattleTrackerTabHintBanner: View {
    let suggestedTab: BattleTrackerSectionTab
    var gameSystemId: GameSystemId = .default
    let onSwitch: () -> Void

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        Button(action: onSwitch) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: suggestedTab.systemImage)
                    .foregroundStyle(Color.accentOnSurface)
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestedTabTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(hintDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Text(String(localized: "Go"))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(Color.accentOnSurface)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accentHighlightCard()
        .accessibilityLabel(suggestedTabAccessibilityLabel)
        .accessibilityHint(hintDetail)
        .accessibilityIdentifier("battleTracker.tabHint")
    }

    private var suggestedTabTitle: String {
        String(localized: "Suggested: \(suggestedTab.title) tab")
    }

    private var suggestedTabAccessibilityLabel: String {
        String(localized: "Suggested \(suggestedTab.title) tab")
    }

    private var hintDetail: String {
        switch suggestedTab {
        case .setup:
            playContext.capabilities.resolvesWh40kRules
                ? String(localized: "Mission setup steps still need attention.")
                : String(localized: "Deployment or round-opener steps still need attention.")
        case .turn:
            String(localized: "Phase playbook, abilities, and what to do in this phase.")
        case .combat:
            String(localized: "Resolve dice and apply damage here.")
        case .army:
            playContext.armyTabBrowseRulesHint
        }
    }
}
