import Foundation

/// Surfaces Anti-Wizard / Anti-Priest weapon rules at the table — coaching only, no dice automation.
public enum AntiKeywordCoaching {
    public static func coachingLine(weapon: SpearheadWeapon, defender: SpearheadUnit) -> String? {
        guard weapon.hasAntiKeywordAbility else { return nil }

        let isWizard = defender.hasKeyword("Wizard")
        let isPriest = defender.hasKeyword("Priest")

        if weapon.hasAntiWizard, weapon.hasAntiPriest {
            if isWizard || isPriest {
                return String(
                    localized: """
                    Anti-Wizard / Anti-Priest — \(defender.name) has the Wizard or Priest keyword. This weapon can wound them.
                    """
                )
            }
            return String(
                localized: """
                Anti-Wizard / Anti-Priest — \(defender.name) has neither keyword. This weapon cannot wound them.
                """
            )
        }
        if weapon.hasAntiWizard {
            if isWizard {
                return String(
                    localized: "Anti-Wizard — \(defender.name) is a Wizard. This weapon can wound them."
                )
            }
            return String(
                localized: "Anti-Wizard — \(defender.name) is not a Wizard. This weapon cannot wound them."
            )
        }
        if weapon.hasAntiPriest {
            if isPriest {
                return String(
                    localized: "Anti-Priest — \(defender.name) is a Priest. This weapon can wound them."
                )
            }
            return String(
                localized: "Anti-Priest — \(defender.name) is not a Priest. This weapon cannot wound them."
            )
        }
        return nil
    }

    public static func glossaryEntryIds(for weapon: SpearheadWeapon) -> [String] {
        var ids: [String] = []
        if weapon.hasAntiWizard { ids.append("anti-wizard") }
        if weapon.hasAntiPriest { ids.append("anti-priest") }
        return ids
    }
}

extension SpearheadUnit {
    public func hasKeyword(_ keyword: String) -> Bool {
        keywords.contains { $0.localizedCaseInsensitiveCompare(keyword) == .orderedSame }
    }
}

extension SpearheadWeapon {
    public var hasAntiWizard: Bool {
        ability?.localizedCaseInsensitiveContains("anti-wizard") == true
    }

    public var hasAntiPriest: Bool {
        ability?.localizedCaseInsensitiveContains("anti-priest") == true
    }

    public var hasAntiKeywordAbility: Bool {
        hasAntiWizard || hasAntiPriest
    }
}
