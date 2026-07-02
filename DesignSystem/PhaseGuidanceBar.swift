import SwiftUI
import TabletomeDomain

struct PhaseGuidanceBar: View {
    let phase: BattleTurnPhase
    var gameSystemId: GameSystemId = .default

    init(phase: BattleTurnPhase, gameSystemId: GameSystemId = .default) {
        self.phase = phase
        self.gameSystemId = gameSystemId
    }

    init(phase: BattleTurnPhase, gameSystemId: String) {
        self.init(phase: phase, gameSystemId: GameSystemId(resolving: gameSystemId))
    }

    private var quickTips: [String] {
        PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId.rawValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(phase.title)
                        .font(.caption.weight(.semibold))
                    Text(phase.playerFacingSummary(gameSystemId: gameSystemId.rawValue))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !quickTips.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    ForEach(Array(quickTips.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
                            Text("•")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(tip)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            if let ruleSectionId = PhaseContextCoach.ruleSectionId(
                for: phase,
                gameSystemId: gameSystemId.rawValue
            ) {
                NavigationLink(
                    value: RuleSectionLink(
                        gameSystemId: gameSystemId.rawValue,
                        sectionId: ruleSectionId
                    )
                ) {
                    Label(
                        String(localized: "Look up \(phase.title) in Rules"),
                        systemImage: "doc.text"
                    )
                    .font(.caption.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("battleTracker.phaseRulesLink.\(phase.id)")
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("battleTracker.phaseGuidance.\(phase.id)")
    }
}
