import SwiftUI
import TabletomeDomain

struct FactionPickLink: Hashable {
    let factionId: String
}

private struct ArmySearchHit: Identifiable {
    let faction: SpearheadFaction
    let army: SpearheadArmy
    var id: String { army.id }
}

extension ArmySelectionView {
    var factionPickList: some View {
        List {
            if enablesProfilePicker {
                PlayerProfilePicker(
                    profiles: profiles,
                    primaryProfileId: primaryProfileId,
                    selectedProfileId: $selectedProfileId,
                    guestName: $playerName,
                    slotLabel: profileSlotLabel.isEmpty ? String(localized: "Player") : profileSlotLabel
                )
                .onChange(of: selectedProfileId) { _, newValue in
                    guard let newValue, let profile = profiles.first(where: { $0.id == newValue }) else { return }
                    playerName = profile.displayName
                    showsAllCatalogArmies = false
                    applyPreferredArmy(for: profile)
                }
            } else {
                Section {
                    TextField(String(localized: "Name"), text: $playerName)
                        .font(TTFont.body)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .frame(height: 44)
                        .background(
                            TTColor.sunken,
                            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                        )
                        .accessibilityIdentifier("guidedMatch.playerNameField")
                } header: {
                    TTSectionHeader(String(localized: "Name"))
                }
            }

            if trimmedArmySearch.isEmpty {
                factionGridSections
            } else {
                armySearchResults
            }
        }
        .ttGroupedList()
        .accessibilityIdentifier("guidedMatch.factionPicker")
    }

    @ViewBuilder
    private var factionGridSections: some View {
        ForEach(SpearheadAlliance.allCases, id: \.self) { alliance in
            let group = factions
                .filter { $0.alliance == alliance }
                .sorted { $0.name < $1.name }
            if !group.isEmpty {
                Section {
                    LazyVGrid(columns: gridColumns, spacing: DesignTokens.Spacing.sm) {
                        ForEach(group) { faction in
                            NavigationLink(value: FactionPickLink(factionId: faction.id)) {
                                factionTile(faction)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("guidedMatch.faction.\(faction.id)")
                        }
                    }
                    .padding(.vertical, DesignTokens.Spacing.xs)
                } header: {
                    TTSectionHeader(allianceTitle(alliance))
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        if dynamicTypeSize.needsLayoutAdaptation {
            return [GridItem(.flexible())]
        }
        return [GridItem(.adaptive(minimum: 104), spacing: DesignTokens.Spacing.sm)]
    }

    private func factionTile(_ faction: SpearheadFaction) -> some View {
        let selected = faction.id == selectedFactionId
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(factionInitials(faction.name))
                .font(TTFont.numericSmall)
                .foregroundStyle(TTColor.inkPrimary)
                .frame(width: DesignTokens.Size.iconTile, height: DesignTokens.Size.iconTile)
                .background(TTColor.sunken, in: Circle())
            Text(faction.name)
                .font(TTFont.subheadline.weight(.semibold))
                .foregroundStyle(TTColor.inkPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(armyCountLabel(faction.armies.count))
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(DesignTokens.Spacing.sm)
        .background(TTColor.raised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(selected ? TTColor.brandFill : TTColor.stroke, lineWidth: selected ? 2 : 1)
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    @ViewBuilder
    private var armySearchResults: some View {
        let factionHits = factions.filter(factionMatches).sorted { $0.name < $1.name }
        let armyHits = factions.flatMap { faction in
            faction.armies.filter(armyMatches).map { ArmySearchHit(faction: faction, army: $0) }
        }
        if factionHits.isEmpty, armyHits.isEmpty {
            Section {
                TTEmptyState(
                    title: String(localized: "No matches"),
                    message: String(localized: "Try a faction or army name."),
                    systemImage: "magnifyingglass"
                )
            }
        } else {
            if !factionHits.isEmpty {
                Section {
                    ForEach(factionHits) { faction in
                        NavigationLink(value: FactionPickLink(factionId: faction.id)) {
                            TTRow(title: faction.name, subtitle: allianceTitle(faction.alliance))
                        }
                        .accessibilityIdentifier("guidedMatch.faction.\(faction.id)")
                    }
                } header: {
                    TTSectionHeader(String(localized: "Factions"))
                }
            }
            if !armyHits.isEmpty {
                Section {
                    ForEach(armyHits, id: \.army.id) { hit in
                        NavigationLink(value: FactionPickLink(factionId: hit.faction.id)) {
                            TTRow(title: hit.army.name, subtitle: hit.faction.name)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            select(army: hit.army, faction: hit.faction)
                        })
                        .accessibilityIdentifier("guidedMatch.army.\(hit.army.id)")
                    }
                } header: {
                    TTSectionHeader(String(localized: "Armies"))
                }
            }
        }
    }

    private func allianceTitle(_ alliance: SpearheadAlliance) -> String {
        switch alliance {
        case .order: String(localized: "Order")
        case .chaos: String(localized: "Chaos")
        case .death: String(localized: "Death")
        case .destruction: String(localized: "Destruction")
        }
    }

    private func factionInitials(_ name: String) -> String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? String(name.prefix(1)).uppercased() : text
    }

    private func armyCountLabel(_ count: Int) -> String {
        count == 1
            ? String(localized: "1 army")
            : String(localized: "\(count) armies")
    }
}
