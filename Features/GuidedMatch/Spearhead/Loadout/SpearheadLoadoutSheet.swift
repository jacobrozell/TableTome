import SwiftUI
import TabletomeDomain

/// Combined loadout sheet for regiment ability + enhancement selection with confirm.
struct SpearheadLoadoutSheet: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var currentPlayerIsOne = true

    private var playerOneComplete: Bool {
        viewModel.matchState.playerOne.regimentAbilityId != nil &&
        viewModel.matchState.playerOne.enhancementId != nil
    }

    private var playerTwoComplete: Bool {
        viewModel.matchState.playerTwo.regimentAbilityId != nil &&
        viewModel.matchState.playerTwo.enhancementId != nil
    }

    private var bothComplete: Bool {
        playerOneComplete && playerTwoComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    SpearheadLoadoutPlayerToggle(
                        viewModel: viewModel,
                        currentPlayerIsOne: $currentPlayerIsOne,
                        playerOneComplete: playerOneComplete,
                        playerTwoComplete: playerTwoComplete
                    )
                    SpearheadLoadoutProgressIndicator(
                        viewModel: viewModel,
                        currentPlayerIsOne: currentPlayerIsOne
                    )
                    SpearheadLoadoutRegimentPicker(
                        viewModel: viewModel,
                        ruleSections: ruleSections,
                        currentPlayerIsOne: currentPlayerIsOne
                    )
                    SpearheadLoadoutEnhancementPicker(
                        viewModel: viewModel,
                        ruleSections: ruleSections,
                        currentPlayerIsOne: currentPlayerIsOne
                    )
                    confirmSection
                }
                .padding(DesignTokens.Spacing.md)
            }
            .navigationTitle("Pre-Battle Loadout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .glossaryEntryNavigation()
        }
        .accessibilityIdentifier("spearhead.loadoutSheet")
    }

    // MARK: - Confirm Section

    @ViewBuilder
    private var confirmSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            if bothComplete {
                loadoutSummary
            }

            Button {
                if bothComplete {
                    onConfirm()
                    dismiss()
                } else if currentPlayerIsOne && playerOneComplete {
                    currentPlayerIsOne = false
                } else if !currentPlayerIsOne && playerTwoComplete && !playerOneComplete {
                    currentPlayerIsOne = true
                }
            } label: {
                HStack {
                    if bothComplete {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Confirm Loadout")
                    } else if currentPlayerIsOne && playerOneComplete {
                        Text("Continue to \(viewModel.matchState.playerTwo.playerName)")
                        Image(systemName: "arrow.right")
                    } else {
                        Text("Select options above")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(bothComplete ? Color.green : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(CardSurface.shape(radius: DesignTokens.Radius.nested))
            }
            .disabled(!playerOneComplete && currentPlayerIsOne)
            .disabled(!playerTwoComplete && !currentPlayerIsOne && !bothComplete)
            .accessibilityIdentifier("loadout.confirmButton")
        }
        .padding(.top, DesignTokens.Spacing.md)
    }

    @ViewBuilder
    private var loadoutSummary: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Loadout Ready")
                .font(.headline)
                .foregroundStyle(.green)

            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                playerSummaryColumn(
                    name: viewModel.matchState.playerOne.playerName,
                    regiment: viewModel.regimentAbility(for: viewModel.matchState.playerOne),
                    enhancement: viewModel.enhancement(for: viewModel.matchState.playerOne)
                )
                playerSummaryColumn(
                    name: viewModel.matchState.playerTwo.playerName,
                    regiment: viewModel.regimentAbility(for: viewModel.matchState.playerTwo),
                    enhancement: viewModel.enhancement(for: viewModel.matchState.playerTwo)
                )
            }
        }
        .surfaceCard()
    }

    @ViewBuilder
    private func playerSummaryColumn(name: String, regiment: ArmyRuleOption?, enhancement: ArmyRuleOption?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.caption.weight(.semibold))
            if let regiment {
                Text("⚔️ \(regiment.name)")
                    .font(.caption)
            }
            if let enhancement {
                HStack(spacing: 4) {
                    Text("✨ \(enhancement.name)")
                        .font(.caption)
                    if let effect = ParsedEnhancementEffect.parse(from: enhancement.summary) {
                        Text(effect.badge)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(effect.color.opacity(0.2), in: Capsule())
                            .foregroundStyle(effect.color)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Loadout Option Card

struct LoadoutOptionCard: View {
    let option: ArmyRuleOption
    let isSelected: Bool
    let gameSystemId: String
    let ruleSections: [RuleSection]
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.name)
                            .font(.subheadline.weight(.semibold))

                        if let effect = ParsedEnhancementEffect.parse(from: option.summary) {
                            battleEffectBadge(effect)
                        }
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                Text(option.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let hint = option.newPlayerHint {
                    Label(hint, systemImage: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding(DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color.green.opacity(0.1) : Color(.tertiarySystemFill).opacity(0.5),
                in: CardSurface.shape(radius: DesignTokens.Radius.nested)
            )
            .overlay(
                CardSurface.shape(radius: DesignTokens.Radius.nested)
                    .strokeBorder(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("loadout.option.\(option.id)")
    }

    @ViewBuilder
    private func battleEffectBadge(_ effect: ParsedEnhancementEffect) -> some View {
        HStack(spacing: 4) {
            Image(systemName: effect.icon)
            Text(effect.badge)
        }
        .font(.caption.weight(.medium))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(effect.color.opacity(0.15), in: Capsule())
        .foregroundStyle(effect.color)
    }
}

// MARK: - Effect Parser

struct ParsedEnhancementEffect {
    let badge: String
    let icon: String
    let color: Color

    static func parse(from text: String) -> ParsedEnhancementEffect? {
        let lower = text.lowercased()

        // Ward detection
        if let match = lower.firstMatch(of: /ward\s*\(?\s*(\d+)\+?\)?/) {
            let value = match.1
            return ParsedEnhancementEffect(badge: "Ward \(value)+", icon: "sparkles", color: .purple)
        }
        if lower.contains("ward (") || lower.contains("ward(") {
            return ParsedEnhancementEffect(badge: "Ward", icon: "sparkles", color: .purple)
        }

        // Hit/wound bonuses
        if lower.contains("+1 to hit") {
            return ParsedEnhancementEffect(badge: "+1 Hit", icon: "target", color: .blue)
        }
        if lower.contains("+1 to wound") {
            return ParsedEnhancementEffect(badge: "+1 Wound", icon: "burst.fill", color: .orange)
        }

        // Save bonuses
        if lower.contains("+1 to save") || lower.contains("improve.*save") {
            return ParsedEnhancementEffect(badge: "+1 Save", icon: "shield.fill", color: .green)
        }

        // Damage bonuses
        if lower.contains("+1 damage") {
            return ParsedEnhancementEffect(badge: "+1 Damage", icon: "flame.fill", color: .red)
        }

        // Once per battle abilities
        if lower.contains("once per battle") {
            return ParsedEnhancementEffect(badge: "1× Use", icon: "star.fill", color: .yellow)
        }

        return nil
    }
}
