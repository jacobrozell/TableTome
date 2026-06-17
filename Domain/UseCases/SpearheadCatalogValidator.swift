import Foundation

public struct SpearheadCatalogValidationIssue: Equatable, Sendable {
    public let path: String
    public let message: String
}

public enum SpearheadCatalogValidator {
    public static func validate(catalog: SpearheadCatalog, details: [String: SpearheadArmyDetail] = [:]) -> [SpearheadCatalogValidationIssue] {
        var issues: [SpearheadCatalogValidationIssue] = []

        var armyIds = Set<String>()
        for faction in catalog.factions {
            for army in faction.armies {
                if armyIds.contains(army.id) {
                    issues.append(.init(path: army.id, message: "Duplicate army id"))
                }
                armyIds.insert(army.id)
                issues.append(contentsOf: validateArmy(army, path: "\(faction.id)/\(army.id)"))
            }
        }

        for (detailId, detail) in details {
            if !armyIds.contains(detailId) {
                issues.append(.init(path: detailId, message: "Detail file references unknown army id"))
            }
            if detail.armyId != detailId {
                issues.append(.init(path: detailId, message: "Detail filename and armyId mismatch"))
            }
        }

        return issues
    }

    private static func validateArmy(_ army: SpearheadArmy, path: String) -> [SpearheadCatalogValidationIssue] {
        var issues: [SpearheadCatalogValidationIssue] = []
        let abilities = BattleAbilityCatalog.abilities(for: army)
        let abilityIds = abilities.map(\.id)
        let uniqueAbilityIds = Set(abilityIds)
        if uniqueAbilityIds.count != abilityIds.count {
            issues.append(.init(path: path, message: "Duplicate namespaced ability id"))
        }

        for unit in army.units {
            for ability in unit.abilities where ability.phases.isEmpty && !ability.isPassive {
                issues.append(.init(
                    path: "\(path)/\(unit.id)/\(ability.id)",
                    message: "Non-passive ability missing phases"
                ))
            }
        }

        return issues
    }
}
