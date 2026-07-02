import SwiftUI
import TabletomeDomain

struct StickyPhaseHeader: View {
    let round: Int
    let phaseTitle: String
    let playerName: String
    var gameSystemId: GameSystemId = .default
    var compact: Bool = false

    init(
        round: Int,
        phaseTitle: String,
        playerName: String,
        gameSystemId: GameSystemId = .default,
        compact: Bool = false
    ) {
        self.round = round
        self.phaseTitle = phaseTitle
        self.playerName = playerName
        self.gameSystemId = gameSystemId
        self.compact = compact
    }

    init(
        round: Int,
        phaseTitle: String,
        playerName: String,
        gameSystemId: String,
        compact: Bool = false
    ) {
        self.init(
            round: round,
            phaseTitle: phaseTitle,
            playerName: playerName,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            compact: compact
        )
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var playEngine: PlayEngineConfig {
        GameSystemPlayContext.context(for: gameSystemId).playEngine
    }

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(playEngine.roundLabel(round: round))
                            .font(.subheadline.weight(.semibold))
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(playerName)
                            .font(.subheadline)
                    }
                    Text(phaseTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentOnSurface)
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(playEngine.roundLabel(round: round))
                        .font(.subheadline.weight(.semibold))
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(playerName)
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(phaseTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentOnSurface)
                }
            }
        }
        .padding(.horizontal, compact ? 0 : DesignTokens.Spacing.md)
        .padding(.vertical, compact ? 0 : DesignTokens.Spacing.sm)
        .background {
            if !compact {
                Rectangle().fill(.bar)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stickyPhaseAccessibilityLabel)
        .accessibilityIdentifier("battleTracker.stickyPhaseHeader")
    }

    private var stickyPhaseAccessibilityLabel: String {
        [
            playEngine.roundLabel(round: round),
            playerName,
            phaseTitle
        ].joined(separator: ", ")
    }
}
