import SwiftUI
import TabletomeDomain

/// Expandable unit row showing wounds, stats, weapons, and inline combat resolver.
struct SpearheadUnitRow: View {
    let unit: SpearheadUnit
    let unitKey: String
    let wounds: Int
    let totalWounds: Int
    let isExpanded: Bool
    let isDefending: Bool
    let relevance: UnitPhaseRelevance
    let currentPhase: BattleTurnPhase
    let isActivePlayer: Bool
    let resolverContext: InlineResolverContext?
    let opponentUnits: [SpearheadUnit]
    let opponentArmy: SpearheadArmy?
    let opponentWoundsRemaining: [String: Int]
    var opponentEnhancement: ArmyRuleOption?
    var opponentGeneralUnitId: String?
    let onTap: () -> Void
    let onSelectWeapon: (String) -> Void
    let onSelectTarget: (String?) -> Void
    let onSetWounds: (Int) -> Void
    let onApplyDamage: (Int) -> Void
    let onCancelResolver: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isDestroyed: Bool {
        wounds <= 0
    }

    private var phaseIcon: String {
        if isDestroyed { return "xmark.circle.fill" }
        if unit.canShoot && currentPhase == .shooting { return "scope" }
        if !unit.weapons.filter({ !$0.isRanged }).isEmpty && (currentPhase == .combat || currentPhase == .anyCombat) {
            return "burst.fill"
        }
        return "circle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            compactRow
            if isExpanded && !isDestroyed {
                expandedContent
            }
            if let context = resolverContext {
                inlineResolver(context: context)
            }
        }
        .surfaceCard(padding: 0)
        .opacity(isDestroyed ? 0.5 : 1.0)
        .overlay {
            if isDefending {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(Color.orange, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("spearheadBattle.unitRow.\(unitKey)")
    }

    // MARK: - Compact Row

    @ViewBuilder
    private var compactRow: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: phaseIcon)
                    .font(.caption)
                    .foregroundStyle(relevance == .primary ? Color.accentColor : Color.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isDestroyed ? .secondary : .primary)
                        .strikethrough(isDestroyed)
                        .lineLimit(1)

                    if !isExpanded {
                        keywordBadges
                    }
                }

                Spacer()

                woundIndicator

                if !isDestroyed && isActivePlayer && showsQuickAction {
                    quickActionButton
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(DesignTokens.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(compactAccessibilityLabel)
    }

    @ViewBuilder
    private var woundIndicator: some View {
        HStack(spacing: 4) {
            woundDots
            Text("\(wounds)/\(totalWounds)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var woundDots: some View {
        let filled = min(wounds, 8)
        let empty = min(totalWounds - wounds, 8 - filled)

        HStack(spacing: 2) {
            ForEach(0..<filled, id: \.self) { _ in
                Circle()
                    .fill(woundColor)
                    .frame(width: 6, height: 6)
            }
            ForEach(0..<empty, id: \.self) { _ in
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var woundColor: Color {
        let ratio = Double(wounds) / Double(totalWounds)
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }

    private var showsQuickAction: Bool {
        switch currentPhase {
        case .shooting: return unit.canShoot
        case .combat, .anyCombat: return unit.weapons.contains { !$0.isRanged }
        default: return false
        }
    }

    @ViewBuilder
    private var quickActionButton: some View {
        Button {
            if let weapon = actionWeapon {
                onSelectWeapon(weapon.id)
            }
        } label: {
            Text(quickActionTitle)
                .font(.caption.weight(.medium))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var quickActionTitle: String {
        switch currentPhase {
        case .shooting: return String(localized: "Shoot")
        case .combat, .anyCombat: return String(localized: "Fight")
        default: return String(localized: "Act")
        }
    }

    private var actionWeapon: SpearheadWeapon? {
        switch currentPhase {
        case .shooting:
            return unit.weapons.first { $0.isRanged }
        case .combat, .anyCombat:
            return unit.weapons.first { !$0.isRanged }
        default:
            return unit.weapons.first
        }
    }

    private var primaryWeapon: SpearheadWeapon? {
        switch currentPhase {
        case .shooting:
            return unit.weapons.first { $0.isRanged }
        case .combat, .anyCombat:
            return unit.weapons.first { !$0.isRanged }
        default:
            return unit.weapons.first
        }
    }

    private func weaponSummary(_ weapon: SpearheadWeapon) -> String {
        var parts: [String] = []
        if let range = weapon.rangeInches, weapon.isRanged {
            parts.append("\(range)\"")
        }
        parts.append("\(weapon.attacks)A")
        parts.append("\(weapon.hit)+ hit")
        return parts.joined(separator: " · ")
    }

    private var compactAccessibilityLabel: String {
        var label = unit.name
        label += ", \(wounds) of \(totalWounds) wounds"
        if isDestroyed {
            label += ", destroyed"
        }
        return label
    }

    // MARK: - Keywords

    @ViewBuilder
    private var keywordBadges: some View {
        let badges = priorityKeywords
        if !badges.isEmpty {
            HStack(spacing: 4) {
                ForEach(badges.prefix(4), id: \.self) { keyword in
                    keywordBadge(keyword)
                }
                if badges.count > 4 {
                    Text("+\(badges.count - 4)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        } else if let weapon = primaryWeapon {
            Text(weaponSummary(weapon))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func keywordBadge(_ keyword: String) -> some View {
        let style = keywordStyle(for: keyword)
        Text(keyword)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(style.background, in: Capsule())
            .foregroundStyle(style.foreground)
    }

    private var priorityKeywords: [String] {
        var result: [String] = []

        // Ward is most important for combat
        if let ward = unit.keywords.first(where: { $0.lowercased().contains("ward") }) {
            result.append(ward)
        }

        // Unit type keywords
        let typeKeywords = ["Hero", "Monster", "Wizard", "Priest", "War Machine"]
        for keyword in typeKeywords {
            if unit.keywords.contains(where: { $0.caseInsensitiveCompare(keyword) == .orderedSame }) {
                result.append(keyword)
            }
        }

        // Special abilities from keywords
        let specialKeywords = ["Fly", "Champion", "Musician", "Standard Bearer"]
        for keyword in specialKeywords {
            if unit.keywords.contains(where: { $0.caseInsensitiveCompare(keyword) == .orderedSame }) {
                result.append(keyword)
            }
        }

        return result
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
        return (Color(.tertiarySystemFill), Color.secondary)
    }

    // MARK: - Expanded Content

    @State private var showsFullDetailSheet = false

    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Divider()

            statsRow
            keywordsSection
            woundsEditor
            weaponsList

            if !unit.abilities.isEmpty {
                abilitiesList
            }

            fullDetailsButton
        }
        .padding(DesignTokens.Spacing.sm)
        .sheet(isPresented: $showsFullDetailSheet) {
            SpearheadUnitDetailSheet(
                unit: unit,
                unitKey: unitKey,
                wounds: wounds,
                totalWounds: totalWounds,
                onSetWounds: onSetWounds
            )
        }
    }

    @ViewBuilder
    private var keywordsSection: some View {
        if !unit.keywords.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Keywords")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: 4) {
                    ForEach(unit.keywords, id: \.self) { keyword in
                        keywordBadge(keyword)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var fullDetailsButton: some View {
        Button {
            showsFullDetailSheet = true
        } label: {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                Text("View Full Details")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("spearheadBattle.unitRow.fullDetails")
    }

    @ViewBuilder
    private var statsRow: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if let move = unit.move {
                statBadge(label: "Move", value: move)
            }
            if let save = unit.save {
                statBadge(label: "Save", value: "\(save)+")
            }
            if let control = unit.control {
                statBadge(label: "Control", value: "\(control)")
            }
        }
    }

    @ViewBuilder
    private func statBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(minWidth: 50)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }

    @ViewBuilder
    private var woundsEditor: some View {
        HStack {
            Text("Wounds")
                .font(.subheadline)
            Spacer()
            Stepper(value: Binding(
                get: { wounds },
                set: { onSetWounds($0) }
            ), in: 0...totalWounds) {
                Text("\(wounds)/\(totalWounds)")
                    .font(.subheadline.monospacedDigit())
            }
        }
    }

    @ViewBuilder
    private var weaponsList: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Weapons")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(unit.weapons, id: \.id) { weapon in
                weaponRow(weapon)
            }
        }
    }

    @ViewBuilder
    private func weaponRow(_ weapon: SpearheadWeapon) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.name)
                    .font(.subheadline)
                weaponStats(weapon)
            }
            Spacer()
            if isActivePlayer && weaponMatchesPhase(weapon) {
                Button {
                    onSelectWeapon(weapon.id)
                } label: {
                    Text(weapon.isRanged ? "Shoot" : "Fight")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    @ViewBuilder
    private func weaponStats(_ weapon: SpearheadWeapon) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if let range = weapon.rangeInches, weapon.isRanged {
                Text("\(range)\"")
            }
            Text("\(weapon.attacks)A")
            Text("\(weapon.hit)+")
            Text("\(weapon.wound)+")
            if weapon.rend != 0 {
                Text("-\(weapon.rend)")
            }
            Text("\(weapon.damage)D")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func weaponMatchesPhase(_ weapon: SpearheadWeapon) -> Bool {
        switch currentPhase {
        case .shooting: return weapon.isRanged
        case .combat, .anyCombat: return !weapon.isRanged
        default: return true
        }
    }

    @ViewBuilder
    private var abilitiesList: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Abilities")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(unit.abilities, id: \.id) { ability in
                VStack(alignment: .leading, spacing: 2) {
                    Text(ability.name)
                        .font(.caption.weight(.medium))
                    Text(ability.effect)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            }
        }
    }

    // MARK: - Inline Resolver

    @ViewBuilder
    private func inlineResolver(context: InlineResolverContext) -> some View {
        let defenderIsGeneral: Bool = {
            guard let defenderKey = context.defenderKey,
                  let generalId = opponentGeneralUnitId else { return false }
            let unitId = defenderKey.split(separator: ":").last.map(String.init) ?? defenderKey
            return unitId == generalId
        }()

        VStack(alignment: .leading, spacing: 0) {
            Divider()
            SpearheadInlineResolver(
                context: context,
                attackerUnit: unit,
                defenderUnits: opponentUnits,
                defenderArmy: opponentArmy,
                defenderWoundsRemaining: opponentWoundsRemaining,
                defenderEnhancement: opponentEnhancement,
                defenderIsGeneral: defenderIsGeneral,
                onSelectTarget: onSelectTarget,
                onApplyDamage: onApplyDamage,
                onCancel: onCancelResolver
            )
            .padding(DesignTokens.Spacing.sm)
        }
    }
}
