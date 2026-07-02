import SwiftUI
import TabletomeDomain

struct GameGuideWh40kStarterArmiesSection: View {
    let gameSystemId: String
    let featuredArmyRows: [GameGuideFeaturedArmyRow]

    var body: some View {
        Section {
            ForEach(featuredArmyRows) { row in
                NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: row.army.id)) {
                    GameGuideStarterArmyRow(factionName: row.factionName, army: row.army)
                }
                .accessibilityIdentifier("guide.armyRoster.\(row.army.id)")
            }
        } header: {
            Text(String(localized: "Starter Set Armies"))
        } footer: {
            Text(String(localized: "Datasheets, abilities, and battle tools for the Armageddon launch box armies."))
        }
    }
}

struct GameGuideFeaturedArmiesSection: View {
    let gameSystemId: String
    let featuredArmyRows: [GameGuideFeaturedArmyRow]
    let sectionTitle: String
    let sectionFooter: String

    var body: some View {
        Section {
            ForEach(featuredArmyRows) { row in
                NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: row.army.id)) {
                    GameGuideStarterArmyRow(factionName: row.factionName, army: row.army)
                }
                .accessibilityIdentifier("guide.armyRoster.\(row.army.id)")
            }
        } header: {
            Text(sectionTitle)
        } footer: {
            Text(sectionFooter)
        }
    }
}
