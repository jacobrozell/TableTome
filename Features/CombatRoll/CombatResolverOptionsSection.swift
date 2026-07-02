import SwiftUI
import TabletomeDomain

struct CombatResolverOptionsSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @Binding var showsAdvancedOptions: Bool
    @Binding var diceInputModeRaw: String
    let showsDiceInputMode: Bool
    let isEmbedded: Bool
    let accessibilityPrefix: String

    private var diceInputMode: DiceInputMode {
        get { DiceInputMode(rawValue: diceInputModeRaw) ?? .physical }
        nonmutating set { diceInputModeRaw = newValue.rawValue }
    }

    var body: some View {
        DisclosureGroup(isExpanded: $showsAdvancedOptions) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if showsDiceInputMode {
                    DiceInputModePicker(mode: Binding(
                        get: { diceInputMode },
                        set: { diceInputMode = $0 }
                    ))
                }

                if !viewModel.resolverMatchupBuffs.isEmpty {
                    if !viewModel.resolverAttackerBuffs.isEmpty {
                        buffGroup(title: String(localized: "Attacker"), buffs: viewModel.resolverAttackerBuffs)
                    }
                    if !viewModel.resolverDefenderBuffs.isEmpty {
                        buffGroup(title: String(localized: "Defender"), buffs: viewModel.resolverDefenderBuffs)
                    }
                }

                Toggle(isOn: Binding(
                    get: { viewModel.rollOptions.mortalDamage },
                    set: {
                        viewModel.rollOptions.mortalDamage = $0
                        viewModel.refreshEvaluation()
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Mortal damage"))
                            .font(.subheadline.weight(.semibold))
                        Text(String(localized: "Skip the save roll — damage applies on a successful wound."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .accessibilityIdentifier("\(accessibilityPrefix).mortalDamage")
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            if isEmbedded {
                Label(String(localized: "Extra rules (Ward, modifiers)"), systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
            } else {
                SectionHeader(title: String(localized: "Abilities & Options"), systemImage: "sparkles")
            }
        }
        .modifier(ConditionalResolverCard(enabled: !isEmbedded))
    }

    private func buffGroup(title: String, buffs: [CombatMatchupBuff]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            ForEach(buffs) { buff in
                CombatBuffToggleRow(
                    buff: buff,
                    isOn: viewModel.enabledBuffIds.contains(buff.id)
                ) { enabled in
                    viewModel.toggleBuff(buff, enabled: enabled)
                }
            }
        }
    }
}

struct CombatResolverMultiAttackSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @Binding var showsMultiAttack: Bool
    let ruleSections: [RuleSection]
    let isEmbedded: Bool
    let isSimulated: Bool

    var body: some View {
        if viewModel.selectedAttackerWeapon != nil, viewModel.selectedDefenderUnit?.save != nil {
            DisclosureGroup(isExpanded: $showsMultiAttack) {
                MultiAttackEvaluatorView(
                    viewModel: multiAttackViewModel,
                    weaponName: viewModel.selectedAttackerWeapon?.name ?? "",
                    ruleSections: ruleSections,
                    isSimulated: isSimulated,
                    gameSystemId: viewModel.gameSystemId
                )
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                if isEmbedded {
                    Text(String(localized: "Multiple Attacks"))
                        .font(.subheadline.weight(.semibold))
                } else {
                    SectionHeader(title: String(localized: "Multiple Attacks"), systemImage: "repeat")
                }
            }
            .modifier(ConditionalResolverCard(enabled: !isEmbedded))
        }
    }
}
