import Foundation

public enum BattleRules {
    private static let registry = GameSystemRegistry.bundled

    public static func playContext(for gameSystemId: GameSystemId) -> GameSystemPlayContext {
        playContext(for: gameSystemId.rawValue)
    }

    public static func playContext(for gameSystemId: String) -> GameSystemPlayContext {
        GameSystemPlayContext(gameSystemId: gameSystemId, registry: registry)
    }

    public static func battleRoundCount(gameSystemId: GameSystemId) -> Int {
        battleRoundCount(gameSystemId: gameSystemId.rawValue)
    }

    public static func battleRoundCount(gameSystemId: String) -> Int {
        registry.playEngine(for: gameSystemId)?.battleRoundCount()
            ?? SpearheadBattleRules.battleRoundCount
    }

    public static func mainPhases(gameSystemId: GameSystemId) -> [BattleTurnPhase] {
        mainPhases(gameSystemId: gameSystemId.rawValue)
    }

    public static func mainPhases(gameSystemId: String) -> [BattleTurnPhase] {
        registry.playEngine(for: gameSystemId)?.mainPhases()
            ?? BattleTurnPhase.mainTurnPhases
    }

    public static func initialPhase(gameSystemId: GameSystemId) -> BattleTurnPhase {
        initialPhase(gameSystemId: gameSystemId.rawValue)
    }

    public static func initialPhase(gameSystemId: String) -> BattleTurnPhase {
        registry.playEngine(for: gameSystemId)?.initialPhase()
            ?? .deployment
    }

    public static func roundLabel(round: Int, gameSystemId: GameSystemId) -> String {
        roundLabel(round: round, gameSystemId: gameSystemId.rawValue)
    }

    public static func roundLabel(round: Int, gameSystemId: String) -> String {
        registry.playEngine(for: gameSystemId)?.roundLabel(round: round)
            ?? SpearheadBattleRules.roundLabel(round: round)
    }

    public static func clampBattleRound(_ round: Int, gameSystemId: GameSystemId) -> Int {
        clampBattleRound(round, gameSystemId: gameSystemId.rawValue)
    }

    public static func clampBattleRound(_ round: Int, gameSystemId: String) -> Int {
        registry.playEngine(for: gameSystemId)?.clampBattleRound(round)
            ?? SpearheadBattleRules.clampBattleRound(round)
    }

    public static func isStarCraft(_ gameSystemId: GameSystemId) -> Bool {
        isStarCraft(gameSystemId.rawValue)
    }

    public static func isStarCraft(_ gameSystemId: String) -> Bool {
        playContext(for: gameSystemId).isStarCraft
    }

    public static func isWh40k(_ gameSystemId: GameSystemId) -> Bool {
        isWh40k(gameSystemId.rawValue)
    }

    public static func isWh40k(_ gameSystemId: String) -> Bool {
        playContext(for: gameSystemId).isWh40k
    }

    public static func isCombatPatrol(_ gameSystemId: GameSystemId) -> Bool {
        isCombatPatrol(gameSystemId.rawValue)
    }

    public static func isCombatPatrol(_ gameSystemId: String) -> Bool {
        playContext(for: gameSystemId).isCombatPatrol
    }

    public static func isSpearhead(_ gameSystemId: GameSystemId) -> Bool {
        isSpearhead(gameSystemId.rawValue)
    }

    public static func isSpearhead(_ gameSystemId: String) -> Bool {
        playContext(for: gameSystemId).isSpearhead
    }

    public static func turnStartPhase(gameSystemId: GameSystemId) -> BattleTurnPhase {
        turnStartPhase(gameSystemId: gameSystemId.rawValue)
    }

    public static func turnStartPhase(gameSystemId: String) -> BattleTurnPhase {
        registry.playEngine(for: gameSystemId)?.turnStartPhase()
            ?? .hero
    }

    public static func nextMainPhase(
        after phase: BattleTurnPhase,
        gameSystemId: GameSystemId
    ) -> BattleTurnPhase? {
        nextMainPhase(after: phase, gameSystemId: gameSystemId.rawValue)
    }

    public static func nextMainPhase(after phase: BattleTurnPhase, gameSystemId: String) -> BattleTurnPhase? {
        registry.playEngine(for: gameSystemId)?.nextMainPhase(after: phase)
    }

    public static func descriptor(for gameSystemId: GameSystemId) -> GameSystemDescriptor? {
        descriptor(for: gameSystemId.rawValue)
    }

    public static func descriptor(for gameSystemId: String) -> GameSystemDescriptor? {
        registry.descriptor(for: gameSystemId)
    }

    public static func capabilities(for gameSystemId: GameSystemId) -> PlayCapabilities? {
        capabilities(for: gameSystemId.rawValue)
    }

    public static func capabilities(for gameSystemId: String) -> PlayCapabilities? {
        registry.capabilities(for: gameSystemId)
    }
}
