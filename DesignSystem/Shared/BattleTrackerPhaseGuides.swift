import SwiftUI
import TabletomeDomain

struct PileInGuideCard: View {
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(
                    String(
                        localized: """
                        At the start of the combat phase, before any attack rolls: models not already in base contact \
                        with the enemy can pile in. Each may move up to 3" toward the closest enemy model and must \
                        end closer to an enemy than it started.
                        """
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                Text(String(localized: "Units already in combat do not pile in — they fight from where they are."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)

                if !NewPlayerTipsStore.hasDismissedPileInGuide {
                    Button(String(localized: "Got it")) {
                        NewPlayerTipsStore.dismissPileInGuide()
                        isExpanded = false
                    }
                    .buttonStyle(.bordered)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.pileInGuide.dismiss")
                }
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "Pile in reminder"), systemImage: "arrow.down.right.circle")
                .font(.subheadline.weight(.semibold))
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.pileInGuide")
        .onAppear {
            isExpanded = !NewPlayerTipsStore.hasDismissedPileInGuide
        }
    }
}

struct SeizingInitiativeCallout: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.orange)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Seizing initiative"))
                    .font(.subheadline.weight(.semibold))
                Text(
                    String(
                        localized: """
                        The priority winner may choose to go second instead. That can block refreshing your \
                        battle tactic hand this round unless you are the underdog by 5+ VP.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("battleTracker.seizingInitiative")
    }
}

struct NewMainTurnReminderBanner: View {
    let round: Int

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Label(String(localized: "New battle round"), systemImage: "sparkles")
                .font(.headline)
            Text(
                round == 1
                    ? String(
                        localized: """
                        Round 1: draw a twist card, then each player draws 3 battle tactic cards from the top \
                        of their shuffled deck (no mulligan). Resolve start-of-round abilities before the first turn.
                        """
                    )
                    : String(
                        localized: """
                        Round \(round): draw a twist card, refresh battle tactic hands, then resolve any \
                        start-of-round abilities before the first turn.
                        """
                    )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.newMainTurnReminder")
    }
}
