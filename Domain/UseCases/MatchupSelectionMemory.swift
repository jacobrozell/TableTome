import Foundation

public enum MatchupSelectionMemory: Sendable {
    private static let prefix = "matchup_selection"

    public struct AttackerSelection: Sendable, Equatable {
        public let unitId: String
        public let weaponId: String?

        public init(unitId: String, weaponId: String?) {
            self.unitId = unitId
            self.weaponId = weaponId
        }
    }

    public static func attackerSelection(for armyId: String) -> AttackerSelection? {
        guard let unitId = UserDefaults.standard.string(forKey: attackerUnitKey(armyId: armyId)) else { return nil }
        let weaponId = UserDefaults.standard.string(forKey: attackerWeaponKey(armyId: armyId))
        return AttackerSelection(unitId: unitId, weaponId: weaponId)
    }

    public static func saveAttacker(armyId: String, unitId: String, weaponId: String?) {
        UserDefaults.standard.set(unitId, forKey: attackerUnitKey(armyId: armyId))
        if let weaponId, !weaponId.isEmpty {
            UserDefaults.standard.set(weaponId, forKey: attackerWeaponKey(armyId: armyId))
        } else {
            UserDefaults.standard.removeObject(forKey: attackerWeaponKey(armyId: armyId))
        }
    }

    public static func defenderUnitId(for armyId: String) -> String? {
        UserDefaults.standard.string(forKey: defenderUnitKey(armyId: armyId))
    }

    public static func saveDefender(armyId: String, unitId: String) {
        UserDefaults.standard.set(unitId, forKey: defenderUnitKey(armyId: armyId))
    }

    public static func resetAll() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func attackerUnitKey(armyId: String) -> String {
        "\(prefix)_attacker_unit_\(armyId)"
    }

    private static func attackerWeaponKey(armyId: String) -> String {
        "\(prefix)_attacker_weapon_\(armyId)"
    }

    private static func defenderUnitKey(armyId: String) -> String {
        "\(prefix)_defender_unit_\(armyId)"
    }
}
