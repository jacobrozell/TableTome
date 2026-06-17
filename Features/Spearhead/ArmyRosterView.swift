import SwiftUI
import TabletomeDomain

struct ArmyRosterView: View {
    let army: SpearheadArmy
    let ruleSections: [RuleSection]

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
                        Label(String(localized: "GW Spearhead PDF"), systemImage: "arrow.up.right.square")
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
            if SpearheadFeaturedArmies.isFeatured(army.id) {
                Label(String(localized: "Skaventide / Ultimate Starter Set"), systemImage: "star.fill")
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
            Text(String(localized: "Warscrolls"))
                .font(.headline)
            if army.units.isEmpty {
                Text(String(localized: "Warscroll data is not available for this army yet."))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(army.units) { unit in
                    UnitWarscrollCard(army: army, unit: unit, ruleSections: ruleSections)
                }
            }
        }
    }
}
