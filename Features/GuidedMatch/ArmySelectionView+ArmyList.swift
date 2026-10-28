import SwiftUI
import TabletomeDomain

extension ArmySelectionView {
    func armyPickLevel(factionId: String) -> some View {
        let faction = factions.first { $0.id == factionId }
        return ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let faction {
                    armyCards(for: faction)
                    if let army = faction.armies.first(where: { $0.id == selectedArmyId }) {
                        selectedArmyDetail(army)
                    }
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .navigationTitle(faction?.name ?? title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(TTColor.player(isPlayerOne))
                .frame(height: 4)
                .ignoresSafeArea(edges: .horizontal)
        }
    }

    @ViewBuilder
    private func armyCards(for faction: SpearheadFaction) -> some View {
        let visible = armies(for: faction)
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(visible) { army in
                armyCard(army, faction: faction)
            }
            if enablesProfilePicker, !hiddenArmies(for: faction).isEmpty {
                DisclosureGroup(String(localized: "All Spearhead armies"), isExpanded: $showsAllCatalogArmies) {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(hiddenArmies(for: faction)) { army in
                            armyCard(army, faction: faction)
                        }
                    }
                    .padding(.top, DesignTokens.Spacing.sm)
                }
                Text(String(localized: "Mark armies you own in Players to see them here first."))
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
            }
        }
    }

    private func armyCard(_ army: SpearheadArmy, faction: SpearheadFaction) -> some View {
        let selected = army.id == selectedArmyId && faction.id == selectedFactionId
        return Button {
            select(army: army, faction: faction)
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: selected ? "circle.inset.filled" : "circle")
                        .foregroundStyle(selected ? TTColor.brandFill : TTColor.stroke)
                        .accessibilityHidden(true)
                    Text(army.name)
                        .font(TTFont.headline)
                        .foregroundStyle(TTColor.inkPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    if featuredArmies.isFeatured(army.id) {
                        TTBadge(String(localized: "Starter"), tone: .brand)
                    }
                }
                Text(String(localized: "General: \(army.general)"))
                    .font(TTFont.callout)
                    .foregroundStyle(TTColor.inkSecondary)
                Text(String(localized: "\(army.unitCount) units · \(army.tagline)"))
                    .font(TTFont.callout)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                coverageBadge(for: army)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.md)
            .background(TTColor.raised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                    .strokeBorder(selected ? TTColor.brandFill : TTColor.stroke, lineWidth: selected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("guidedMatch.army.\(army.id)")
        .accessibilityLabel(
            "\(army.name), general \(army.general), \(army.contentCoverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue))"
        )
        .accessibilityHint(selected ? String(localized: "Selected") : String(localized: "Select this army"))
    }

    @ViewBuilder
    private func coverageBadge(for army: SpearheadArmy) -> some View {
        if !GameSystemPlayContext.context(for: gameSystemId).capabilities.showsActivationBar {
            let coverage = army.contentCoverage
            TTBadge(
                coverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue),
                tone: coverageTone(coverage),
                systemImage: coverage.systemImage
            )
            .accessibilityLabel(
                String(
                    localized: "Content: \(coverage.playerFacingTitle(gameSystemId: gameSystemId.rawValue))"
                )
            )
        }
    }

    private func coverageTone(_ coverage: SpearheadContentCoverage) -> TTTone {
        switch coverage {
        case .warscrolls, .battleTracker: .success
        case .matchSetup: .brand
        case .roster: .neutral
        }
    }

    @ViewBuilder
    private func selectedArmyDetail(_ army: SpearheadArmy) -> some View {
        if !army.roster.isEmpty {
            TTSectionHeader(String(localized: "Roster"))
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                ForEach(army.roster, id: \.self) { unit in
                    Text(unit)
                        .font(TTFont.callout)
                        .foregroundStyle(TTColor.inkPrimary)
                }
            }
        }
        if let battleTraitName = army.battleTraitName, !army.battleTraits.isEmpty {
            TTSectionHeader(battleTraitName)
            ForEach(army.battleTraits) { trait in
                ArmyRuleOptionCard(option: trait, isSelected: false)
            }
        }
        if showsUnitReference(for: army) {
            NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId.rawValue, armyId: army.id)) {
                TTRow(title: String(localized: "View Warscrolls"), systemImage: "doc.richtext")
            }
            .accessibilityIdentifier("guidedMatch.unitReference.\(army.id)")
        }
        if let urlString = army.officialRulesURL, let url = URL(string: urlString) {
            Link(destination: url) {
                TTRow(title: String(localized: "Official PDF"), systemImage: "arrow.up.right.square", accessory: .external)
            }
            .accessibilityIdentifier("guidedMatch.officialRules.\(army.id)")
        }
    }
}
