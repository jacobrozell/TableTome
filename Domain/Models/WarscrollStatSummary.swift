import Foundation

public enum WarscrollStatSummary: Sendable {
    public static func weaponCombatProfile(_ weapon: SpearheadWeapon) -> String {
        var parts: [String] = []
        if let range = weapon.rangeInches {
            parts.append("Range \(range)\"")
        }
        parts.append("A \(weapon.attacks)")
        parts.append("Hit \(weapon.hit)+")
        parts.append("Wound \(weapon.wound)+")
        parts.append("Rend \(weapon.rend)")
        parts.append("Dmg \(weapon.damage)")
        return parts.joined(separator: " · ")
    }

    public static func unitDefensiveProfile(_ unit: SpearheadUnit) -> String {
        var parts: [String] = []
        if let save = unit.save {
            parts.append("Save \(save)+")
        }
        if let health = unit.health {
            parts.append("\(health) wounds/model")
        }
        if let move = unit.move {
            parts.append("Move \(move)\"")
        }
        return parts.joined(separator: " · ")
    }

    public static func unitChoiceSubtext(
        _ unit: SpearheadUnit,
        woundsRemaining: Int? = nil
    ) -> String? {
        var parts: [String] = []
        if let save = unit.save {
            parts.append("Save \(save)+")
        }
        if let health = unit.health {
            parts.append("\(health) wounds/model")
        }
        if let woundsRemaining {
            let capacity = UnitWoundCapacity.capacity(for: unit)
            parts.append("\(woundsRemaining)/\(capacity) wounds left")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    public static func unitPickerLabel(_ unit: SpearheadUnit, destroyed: Bool = false) -> String {
        guard destroyed else { return unit.name }
        return String(localized: "\(unit.name) (Destroyed)")
    }
}
