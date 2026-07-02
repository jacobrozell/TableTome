import Foundation

/// Shared copy for batch combat save coaching — keep UI and regression tests aligned.
public enum BatchCombatSaveHint {
    public static func saveReferenceLine(
        saveTarget: Int,
        rend: Int,
        saveNeededOnDice: Int,
        usesWh40kRules: Bool = false
    ) -> String {
        let penetrationLabel = usesWh40kRules
            ? String(localized: "AP")
            : String(localized: "Rend")
        let penetrationValue = usesWh40kRules
            ? "\(rend)"
            : rendLabel(rend)
        let rendNote = rend == 0
            ? ""
            : String(localized: " (Rend \(rendLabel(rend)) subtracts from each roll)")
        return String(
            localized: """
            Save \(saveTarget)+ vs \(penetrationLabel) \(penetrationValue)\(rendNote) — roll \(saveNeededOnDice)+ or higher on each save dice.
            """
        )
    }

    private static func rendLabel(_ rend: Int) -> String {
        rend >= 0 ? "+\(rend)" : "\(rend)"
    }
}
