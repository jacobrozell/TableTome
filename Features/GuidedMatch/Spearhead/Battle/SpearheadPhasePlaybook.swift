import SwiftUI
import TabletomeDomain

/// Phase-specific guidance card with context and advance button.
struct SpearheadPhasePlaybook: View {
    let phase: BattleTurnPhase
    let round: Int
    let canAdvance: Bool
    let nextPhaseTitle: String?
    let shootableUnitCount: Int
    let totalUnitCount: Int
    let onAdvance: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            headerRow
            bodyText
            advanceButton
        }
        .surfaceCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("spearheadBattle.phasePlaybook")
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack {
            Label(phase.title.uppercased(), systemImage: phaseIcon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentOnSurface)
            Spacer()
        }
    }

    private var phaseIcon: String {
        switch phase {
        case .hero: "sparkles"
        case .movement: "figure.walk"
        case .shooting: "scope"
        case .charge: "arrow.right.circle"
        case .combat, .anyCombat: "burst.fill"
        case .endOfTurn, .endOfAnyTurn: "flag.checkered"
        default: "questionmark.circle"
        }
    }

    @ViewBuilder
    private var bodyText: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(phaseDescription)
                .font(.callout)
                .foregroundStyle(.primary)

            if let hint = phaseHint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var phaseDescription: String {
        switch phase {
        case .hero:
            return String(localized: "Activate abilities before moving. Most Spearhead games: skip to Movement.")
        case .movement:
            return String(localized: "Move each unit up to its Move characteristic. Units in combat can only Retreat.")
        case .shooting:
            if shootableUnitCount == 0 {
                return String(localized: "None of your units have ranged weapons this turn.")
            }
            return String(localized: "Pick a unit with ranged weapons, choose a target, roll hit dice.")
        case .charge:
            return String(localized: "Units not in combat can charge. Roll 2D6 — must reach within ½\" of an enemy.")
        case .combat, .anyCombat:
            return String(localized: "Fight with units in melee range. Each unit fights once — mark when done.")
        case .endOfTurn, .endOfAnyTurn:
            return String(localized: "Score objectives you control. Check your battle tactic if you completed it.")
        default:
            return String(localized: "Continue with this phase.")
        }
    }

    private var phaseHint: String? {
        switch phase {
        case .shooting where shootableUnitCount > 0:
            return String(localized: "\(shootableUnitCount) of \(totalUnitCount) units can shoot this phase.")
        case .hero where round == 1:
            return String(localized: "Round 1: Remember to check deployment abilities.")
        default:
            return nil
        }
    }

    @ViewBuilder
    private var advanceButton: some View {
        HStack {
            Spacer()
            Button {
                onAdvance()
            } label: {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    if let next = nextPhaseTitle {
                        Text("Advance to \(next)")
                    } else {
                        Text("End Turn")
                    }
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canAdvance)
            .accessibilityIdentifier("spearheadBattle.advancePhase")
        }
    }
}
