import Foundation

public struct PhasedRoundEngineConfig: Sendable, Equatable {
    public let battleRoundCount: Int
    public let mainPhases: [BattleTurnPhase]
    public let initialPhase: BattleTurnPhase
    public let turnStartPhase: BattleTurnPhase
    public let usesBattleRoundLabel: Bool

    public init(
        battleRoundCount: Int,
        mainPhases: [BattleTurnPhase],
        initialPhase: BattleTurnPhase,
        turnStartPhase: BattleTurnPhase,
        usesBattleRoundLabel: Bool = true
    ) {
        self.battleRoundCount = battleRoundCount
        self.mainPhases = mainPhases
        self.initialPhase = initialPhase
        self.turnStartPhase = turnStartPhase
        self.usesBattleRoundLabel = usesBattleRoundLabel
    }

    public func roundLabel(round: Int) -> String {
        if usesBattleRoundLabel {
            String(localized: "Battle Round \(round) of \(battleRoundCount)")
        } else {
            String(localized: "Round \(round) of \(battleRoundCount)")
        }
    }

    public func clampBattleRound(_ round: Int) -> Int {
        min(battleRoundCount, max(1, round))
    }
}

public struct AlternatingActivationEngineConfig: Sendable, Equatable {
    public let battleRoundCount: Int
    public let mainPhases: [BattleTurnPhase]
    public let initialPhase: BattleTurnPhase

    public init(
        battleRoundCount: Int,
        mainPhases: [BattleTurnPhase],
        initialPhase: BattleTurnPhase
    ) {
        self.battleRoundCount = battleRoundCount
        self.mainPhases = mainPhases
        self.initialPhase = initialPhase
    }

    public func roundLabel(round: Int) -> String {
        String(localized: "Battle Round \(round) of \(battleRoundCount)")
    }

    public func clampBattleRound(_ round: Int) -> Int {
        min(battleRoundCount, max(1, round))
    }
}

public enum PlayEngineConfig: Sendable, Equatable {
    case phasedRound(PhasedRoundEngineConfig)
    case alternatingActivation(AlternatingActivationEngineConfig)

    public var playEngineId: PlayEngineId {
        switch self {
        case .phasedRound: .phasedRound
        case .alternatingActivation: .alternatingActivation
        }
    }

    public func battleRoundCount() -> Int {
        switch self {
        case let .phasedRound(config): config.battleRoundCount
        case let .alternatingActivation(config): config.battleRoundCount
        }
    }

    public func mainPhases() -> [BattleTurnPhase] {
        switch self {
        case let .phasedRound(config): config.mainPhases
        case let .alternatingActivation(config): config.mainPhases
        }
    }

    public func initialPhase() -> BattleTurnPhase {
        switch self {
        case let .phasedRound(config): config.initialPhase
        case let .alternatingActivation(config): config.initialPhase
        }
    }

    public func turnStartPhase() -> BattleTurnPhase {
        switch self {
        case let .phasedRound(config): config.turnStartPhase
        case let .alternatingActivation(config): config.initialPhase
        }
    }

    public func roundLabel(round: Int) -> String {
        switch self {
        case let .phasedRound(config): config.roundLabel(round: round)
        case let .alternatingActivation(config): config.roundLabel(round: round)
        }
    }

    public func clampBattleRound(_ round: Int) -> Int {
        switch self {
        case let .phasedRound(config): config.clampBattleRound(round)
        case let .alternatingActivation(config): config.clampBattleRound(round)
        }
    }

    public func nextMainPhase(after phase: BattleTurnPhase) -> BattleTurnPhase? {
        let phases = mainPhases()
        guard let index = phases.firstIndex(of: phase), index < phases.count - 1 else { return nil }
        return phases[index + 1]
    }
}
