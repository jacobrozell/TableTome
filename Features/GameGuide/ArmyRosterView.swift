import SwiftUI
import TabletomeDomain

struct ArmyRosterView: View {
    let army: SpearheadArmy
    var factionName: String?
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default
    var featuredArmies: GuidedMatchFeaturedArmies = GuidedMatchFeaturedArmies.resolved(for: .default)

    init(
        army: SpearheadArmy,
        factionName: String? = nil,
        ruleSections: [RuleSection],
        gameSystemId: GameSystemId = .default,
        featuredArmies: GuidedMatchFeaturedArmies = GuidedMatchFeaturedArmies.resolved(for: .default)
    ) {
        self.army = army
        self.factionName = factionName
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
        self.featuredArmies = featuredArmies
    }

    init(
        army: SpearheadArmy,
        factionName: String? = nil,
        ruleSections: [RuleSection],
        gameSystemId: String,
        featuredArmies: GuidedMatchFeaturedArmies = GuidedMatchFeaturedArmies.resolved(for: .default)
    ) {
        self.init(
            army: army,
            factionName: factionName,
            ruleSections: ruleSections,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            featuredArmies: featuredArmies
        )
    }

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var usesCatalogUnitTerminology: Bool {
        playContext.usesGuidedBattleTracker
    }

    private var unitsSectionTitle: String {
        usesCatalogUnitTerminology
            ? String(localized: "Units")
            : String(localized: "Warscrolls")
    }

    private var emptyUnitsMessage: String {
        usesCatalogUnitTerminology
            ? String(localized: "Unit data is not available for this army yet.")
            : String(localized: "Warscroll data is not available for this army yet.")
    }

    private var officialRulesLabel: String {
        switch gameSystemId {
        case .scTmg:
            String(localized: "StarCraft TMG rules link")
        case .wh40k11e, .wh40k10eCp:
            String(localized: "Official rules link")
        default:
            String(localized: "Official PDF")
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                overviewSection
                if !army.battleTraits.isEmpty, let traitName = army.battleTraitName {
                    battleTraitsSection(title: traitName)
                }
                unitsSection
                if let urlString = army.officialRulesURL, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Label(officialRulesLabel, systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.ttTertiary)
                    .accessibilityIdentifier("warscroll.officialRules.\(army.id)")
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .navigationTitle(army.name)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("warscroll.roster.\(army.id)")
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if let factionName {
                Text(factionName).ttEyebrow()
            }
            Text(army.name)
                .font(TTFont.title)
                .foregroundStyle(TTColor.inkPrimary)
            TTKeyValueRow(String(localized: "General"), value: army.general)
            TTKeyValueRow(String(localized: "Units"), value: "\(army.unitCount)")
            Text(army.playstyle)
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if featuredArmies.isFeatured(army.id) {
                TTBadge(featuredArmies.starterSetBadge, tone: .brand, style: .soft)
            }
        }
    }

    private func battleTraitsSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTSectionHeader(title)
            ForEach(army.battleTraits) { trait in
                ArmyRuleOptionCard(option: trait, isSelected: false, gameSystemId: gameSystemId.rawValue)
            }
        }
    }

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTSectionHeader(unitsSectionTitle)
            if army.units.isEmpty {
                Text(emptyUnitsMessage)
                    .font(TTFont.callout)
                    .foregroundStyle(TTColor.inkSecondary)
            } else {
                TTCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(army.units) { unit in
                            NavigationLink(value: UnitWarscrollLink(
                                gameSystemId: gameSystemId.rawValue,
                                armyId: army.id,
                                unitId: unit.id
                            )) {
                                unitRow(unit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func unitRow(_ unit: SpearheadUnit) -> some View {
        let isHero = unit.keywords.contains { $0.localizedCaseInsensitiveContains("hero") }
        let count = unit.modelCount ?? 1
        return TTRow(
            title: unit.name,
            subtitle: unit.keywords.joined(separator: " · "),
            badge: isHero ? TTBadge(String(localized: "Hero"), tone: .brand, style: .soft) : nil,
            accessory: count > 1 ? .value("×\(count)") : .chevron
        )
    }
}
