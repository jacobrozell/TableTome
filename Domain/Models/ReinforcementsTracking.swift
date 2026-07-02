import Foundation

public struct ReinforcementCallPrompt: Equatable, Sendable {
    public let activePlayerName: String
    public let destroyedUnitName: String
    public let availableUnits: [ReinforcementUnitRef]

    public init(
        activePlayerName: String,
        destroyedUnitName: String,
        availableUnits: [ReinforcementUnitRef]
    ) {
        self.activePlayerName = activePlayerName
        self.destroyedUnitName = destroyedUnitName
        self.availableUnits = availableUnits
    }
}

public struct ReinforcementUnitRef: Equatable, Sendable, Identifiable {
    public let armyId: String
    public let unitId: String
    public let unitName: String

    public var id: String { UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId) }

    public init(armyId: String, unitId: String, unitName: String) {
        self.armyId = armyId
        self.unitId = unitId
        self.unitName = unitName
    }
}

public struct ReinforcementCallContext: Sendable, Equatable {
    public let gameSystemId: GameSystemId
    public let phase: BattleTurnPhase
    public let activePlayerIsOne: Bool
    public let destroyedArmyId: String
    public let playerOneArmyId: String?
    public let playerTwoArmyId: String?
    public let playerOneArmy: SpearheadArmy?
    public let playerTwoArmy: SpearheadArmy?
    public let playerOneName: String
    public let playerTwoName: String
    public let destroyedUnitName: String
    public let calledUnitKeys: Set<String>

    public init(
        gameSystemId: GameSystemId,
        phase: BattleTurnPhase,
        activePlayerIsOne: Bool,
        destroyedArmyId: String,
        playerOneArmyId: String?,
        playerTwoArmyId: String?,
        playerOneArmy: SpearheadArmy?,
        playerTwoArmy: SpearheadArmy?,
        playerOneName: String,
        playerTwoName: String,
        destroyedUnitName: String,
        calledUnitKeys: Set<String>
    ) {
        self.gameSystemId = gameSystemId
        self.phase = phase
        self.activePlayerIsOne = activePlayerIsOne
        self.destroyedArmyId = destroyedArmyId
        self.playerOneArmyId = playerOneArmyId
        self.playerTwoArmyId = playerTwoArmyId
        self.playerOneArmy = playerOneArmy
        self.playerTwoArmy = playerTwoArmy
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.destroyedUnitName = destroyedUnitName
        self.calledUnitKeys = calledUnitKeys
    }
}

public enum ReinforcementsTracking {
    private static let keyword = "Reinforcements"

    public static func isReinforcementUnit(_ unit: SpearheadUnit) -> Bool {
        unit.keywords.contains { $0.caseInsensitiveCompare(keyword) == .orderedSame }
    }

    public static func reinforcementUnits(in army: SpearheadArmy) -> [SpearheadUnit] {
        army.units.filter(isReinforcementUnit)
    }

    public static func uncalledReinforcementUnits(
        in army: SpearheadArmy,
        calledUnitKeys: Set<String>
    ) -> [SpearheadUnit] {
        reinforcementUnits(in: army).filter { unit in
            let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            return !calledUnitKeys.contains(key)
        }
    }

    public static func isCalledOnTable(
        armyId: String,
        unitId: String,
        calledUnitKeys: Set<String>
    ) -> Bool {
        calledUnitKeys.contains(UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId))
    }

    public static func callPrompt(context: ReinforcementCallContext) -> ReinforcementCallPrompt? {
        guard context.gameSystemId == .aosSpearhead else { return nil }
        guard context.phase == .movement else { return nil }

        let destroyedPlayerIsOne = context.playerOneArmyId == context.destroyedArmyId
        let destroyedPlayerIsTwo = context.playerTwoArmyId == context.destroyedArmyId
        guard destroyedPlayerIsOne || destroyedPlayerIsTwo else { return nil }
        guard destroyedPlayerIsOne != context.activePlayerIsOne else { return nil }

        let activeArmy = context.activePlayerIsOne ? context.playerOneArmy : context.playerTwoArmy
        let activeName = context.activePlayerIsOne ? context.playerOneName : context.playerTwoName
        guard let activeArmy else { return nil }

        let uncalled = uncalledReinforcementUnits(in: activeArmy, calledUnitKeys: context.calledUnitKeys)
        guard !uncalled.isEmpty else { return nil }

        return ReinforcementCallPrompt(
            activePlayerName: activeName,
            destroyedUnitName: context.destroyedUnitName,
            availableUnits: uncalled.map {
                ReinforcementUnitRef(armyId: activeArmy.id, unitId: $0.id, unitName: $0.name)
            }
        )
    }
}
