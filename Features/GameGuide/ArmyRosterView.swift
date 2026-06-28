import SwiftUI
import TabletomeDomain

struct ArmyRosterView: View {
    let army: SpearheadArmy
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default
    var featuredArmies: GuidedMatchFeaturedArmies = SpearheadFeaturedArmies.configuration

    init(
        army: SpearheadArmy,
        ruleSections: [RuleSection],
        gameSystemId: GameSystemId = .default,
        featuredArmies: GuidedMatchFeaturedArmies = SpearheadFeaturedArmies.configuration
    ) {
        self.army = army
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
        self.featuredArmies = featuredArmies
    }

    init(
        army: SpearheadArmy,
        ruleSections: [RuleSection],
        gameSystemId: String,
        featuredArmies: GuidedMatchFeaturedArmies = SpearheadFeaturedArmies.configuration
    ) {
        self.init(
            army: army,
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
            String(localized: "GW Spearhead PDF")
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
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityIdentifier("warscroll.officialRules.\(army.id)")
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(army.name)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("warscroll.roster.\(army.id)")
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(army.general)
                .font(.title3.bold())
            Text(army.tagline)
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(army.playstyle)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            if featuredArmies.isFeatured(army.id) {
                Label(featuredArmies.starterSetBadge, systemImage: "star.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
    }

    private func battleTraitsSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.headline)
            ForEach(army.battleTraits) { trait in
                ArmyRuleOptionCard(option: trait, isSelected: false)
            }
        }
    }

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(unitsSectionTitle)
                .font(.headline)
            if army.units.isEmpty {
                Text(emptyUnitsMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(army.units) { unit in
                    UnitWarscrollCard(
                        army: army,
                        unit: unit,
                        ruleSections: ruleSections,
                        gameSystemId: gameSystemId
                    )
                }
            }
        }
    }
}
