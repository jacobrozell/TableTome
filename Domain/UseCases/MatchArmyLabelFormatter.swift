import Foundation

public enum MatchArmyLabelFormatter: Sendable {
    public static func label(for player: PlayerArmySelection, in catalog: SpearheadCatalog) -> String {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }),
              let army = faction.armies.first(where: { $0.id == player.armyId }) else {
            return String(localized: "Not selected")
        }
        return "\(faction.name) — \(army.name)"
    }
}
