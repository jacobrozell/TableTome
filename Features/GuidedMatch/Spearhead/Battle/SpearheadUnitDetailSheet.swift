import SwiftUI
import TabletomeDomain

/// Full-screen sheet showing everything about a unit: stats, keywords, weapons, abilities.
struct SpearheadUnitDetailSheet: View {
    let unit: SpearheadUnit
    let unitKey: String
    let wounds: Int
    let totalWounds: Int
    let onSetWounds: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    woundsSection
                    statsSection
                    keywordsSection
                    weaponsSection
                    abilitiesSection
                }
                .padding(DesignTokens.Spacing.md)
            }
            .navigationTitle(unit.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .accessibilityIdentifier("spearheadBattle.unitDetailSheet")
    }

    // MARK: - Wounds

    @ViewBuilder
    private var woundsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionLabel(title: "Wounds")

            HStack {
                woundBar
                Spacer()
                woundStepper
            }
            .surfaceCard()
        }
    }

    @ViewBuilder
    private var woundBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(wounds) / \(totalWounds)")
                .font(.title2.weight(.bold).monospacedDigit())

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(woundColor)
                        .frame(width: geo.size.width * CGFloat(wounds) / CGFloat(max(totalWounds, 1)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var woundColor: Color {
        let ratio = Double(wounds) / Double(max(totalWounds, 1))
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }

    @ViewBuilder
    private var woundStepper: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button {
                if wounds > 0 {
                    onSetWounds(wounds - 1)
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(wounds > 0 ? Color.red : Color.secondary)
            }
            .disabled(wounds <= 0)

            Button {
                if wounds < totalWounds {
                    onSetWounds(wounds + 1)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(wounds < totalWounds ? Color.green : Color.secondary)
            }
            .disabled(wounds >= totalWounds)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionLabel(title: "Characteristics")

            HStack(spacing: DesignTokens.Spacing.md) {
                if let move = unit.move {
                    statCard(label: "Move", value: move, icon: "figure.walk")
                }
                if let save = unit.save {
                    statCard(label: "Save", value: "\(save)+", icon: "shield.fill")
                }
                if let control = unit.control {
                    statCard(label: "Control", value: "\(control)", icon: "flag.fill")
                }
                if let ward = parsedWard {
                    statCard(label: "Ward", value: "\(ward)+", icon: "sparkles", highlight: true)
                }
            }
        }
    }

    private var parsedWard: Int? {
        for keyword in unit.keywords {
            let pattern = /[Ww]ard\s*\((\d+)\+\)/
            if let match = keyword.firstMatch(of: pattern), let value = Int(match.1) {
                return value
            }
        }
        return nil
    }

    @ViewBuilder
    private func statCard(label: String, value: String, icon: String, highlight: Bool = false) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(highlight ? Color.purple : Color.secondary)
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(
            highlight ? Color.purple.opacity(0.1) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
        )
    }

    // MARK: - Keywords

    @ViewBuilder
    private var keywordsSection: some View {
        if !unit.keywords.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionLabel(title: "Keywords")

                FlowLayout(spacing: 6) {
                    ForEach(unit.keywords, id: \.self) { keyword in
                        keywordChip(keyword)
                    }
                }
                .surfaceCard()
            }
        }
    }

    @ViewBuilder
    private func keywordChip(_ keyword: String) -> some View {
        let style = keywordStyle(for: keyword)
        Text(keyword)
            .font(.caption.weight(.medium))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 4)
            .background(style.background, in: Capsule())
            .foregroundStyle(style.foreground)
    }

    private func keywordStyle(for keyword: String) -> (background: Color, foreground: Color) {
        let lower = keyword.lowercased()
        if lower.contains("ward") {
            return (Color.purple.opacity(0.2), Color.purple)
        }
        if lower == "hero" {
            return (Color.yellow.opacity(0.2), Color.orange)
        }
        if lower == "wizard" || lower == "priest" {
            return (Color.blue.opacity(0.2), Color.blue)
        }
        if lower == "monster" {
            return (Color.red.opacity(0.2), Color.red)
        }
        if lower == "fly" {
            return (Color.cyan.opacity(0.2), Color.cyan)
        }
        return (Color(.tertiarySystemFill), Color.primary)
    }

    // MARK: - Weapons

    @ViewBuilder
    private var weaponsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionLabel(title: "Weapons")

            ForEach(unit.weapons, id: \.id) { weapon in
                weaponCard(weapon)
            }
        }
    }

    @ViewBuilder
    private func weaponCard(_ weapon: SpearheadWeapon) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: weapon.isRanged ? "scope" : "burst.fill")
                    .foregroundStyle(weapon.isRanged ? Color.blue : Color.orange)
                Text(weapon.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if weapon.isRanged, let range = weapon.rangeInches {
                    Text("\(range)\"")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1), in: Capsule())
                        .foregroundStyle(.blue)
                }
            }

            HStack(spacing: DesignTokens.Spacing.md) {
                weaponStat(label: "Attacks", value: weapon.attacks)
                weaponStat(label: "Hit", value: "\(weapon.hit)+")
                weaponStat(label: "Wound", value: "\(weapon.wound)+")
                weaponStat(label: "Rend", value: weapon.rend == 0 ? "—" : "-\(weapon.rend)", highlight: weapon.rend > 0)
                weaponStat(label: "Damage", value: weapon.damage)
            }

            if let ability = weapon.ability, !ability.isEmpty {
                Text(ability)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .surfaceCard()
    }

    @ViewBuilder
    private func weaponStat(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(highlight ? Color.red : Color.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Abilities

    @ViewBuilder
    private var abilitiesSection: some View {
        if !unit.abilities.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionLabel(title: "Abilities")

                ForEach(unit.abilities, id: \.id) { ability in
                    abilityCard(ability)
                }
            }
        }
    }

    @ViewBuilder
    private func abilityCard(_ ability: TriggeredAbility) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text(ability.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if !ability.phases.isEmpty {
                    phaseBadges(ability.phases)
                }
            }

            Text(ability.effect)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
    }

    @ViewBuilder
    private func phaseBadges(_ phases: [BattleTurnPhase]) -> some View {
        HStack(spacing: 4) {
            ForEach(phases.prefix(2), id: \.self) { phase in
                Text(phase.shortTitle)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(Color.accentOnSurface)
            }
        }
    }
}

// MARK: - Helpers

private struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Simple flow layout for keywords
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

extension BattleTurnPhase {
    var shortTitle: String {
        switch self {
        case .hero: "Hero"
        case .movement: "Move"
        case .shooting: "Shoot"
        case .charge: "Charge"
        case .combat, .anyCombat: "Fight"
        case .endOfTurn, .endOfAnyTurn: "End"
        default: title
        }
    }
}
