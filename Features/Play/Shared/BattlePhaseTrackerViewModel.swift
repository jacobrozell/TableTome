import Foundation
import TabletomeDomain

@MainActor
class BattlePhaseTrackerViewModel: ObservableObject {
    @Published var trackerState: BattleTrackerState
    @Published var activeAbilities: [TriggeredAbility] = []
    @Published var passiveAbilities: [TriggeredAbility] = []
    @Published var contentCoverage: SpearheadContentCoverage = .roster
    @Published var playerOneName = ""
    @Published var playerTwoName = ""
    @Published var armyName = ""
    @Published var activeRegimentAbility: ArmyRuleOption?
    @Published var activeEnhancement: ArmyRuleOption?
    @Published var activeArmy: SpearheadArmy?
    @Published var playerOneArmy: SpearheadArmy?
    @Published var playerTwoArmy: SpearheadArmy?
    @Published var playerOneRegimentAbility: ArmyRuleOption?
    @Published var playerTwoRegimentAbility: ArmyRuleOption?
    @Published var playerOneEnhancement: ArmyRuleOption?
    @Published var playerTwoEnhancement: ArmyRuleOption?
    @Published var playerOneSecondary: ArmyRuleOption?
    @Published var playerTwoSecondary: ArmyRuleOption?
    @Published var activeGotchas: [SpearheadGotcha] = []

    var matchState: GuidedMatchState
    let catalog: SpearheadCatalog
    let gameSystemId: GameSystemId
    let playContext: GameSystemPlayContext
    let trackerEngine: any BattleTrackerEngine

    private let onMatchStateChange: (() -> Void)?

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        initialState: BattleTrackerState? = nil,
        playContext: GameSystemPlayContext? = nil,
        trackerEngine: (any BattleTrackerEngine)? = nil,
        onMatchStateChange: (() -> Void)? = nil
    ) {
        let context = playContext ?? GameSystemPlayContext(gameSystemId: gameSystemId)
        let engine = trackerEngine ?? BattleTrackerEngineFactory.engine(for: context)
        self.gameSystemId = gameSystemId
        self.playContext = context
        self.trackerEngine = engine
        self.matchState = matchState
        self.catalog = catalog
        self.onMatchStateChange = onMatchStateChange
        self.trackerState = initialState ?? BattleTrackerStore.load(gameSystemId: gameSystemId)
        bootstrapTrackerState(using: context)
        syncAutoCompletions()
        refreshAbilities()
    }

    private func bootstrapTrackerState(using context: GameSystemPlayContext) {
        trackerEngine.bootstrap(
            trackerState: &trackerState,
            matchState: matchState,
            playContext: context
        )
    }

    var currentGuideStep: BattleFlowGuideStep? {
        BattleFlowGuide.currentStep(
            matchState: matchState,
            trackerState: trackerState,
            gameSystemId: gameSystemId
        )
    }

    var shootingEligibleUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        return army.units.filter(\.canShoot)
    }

    var shootInCombatEligibleUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        return army.units.filter { unit in
            unit.weapons.contains { $0.hasShootInCombat && $0.isRanged }
        }
    }

    var nextPhaseTitle: String? {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase),
              index < phases.count - 1 else { return nil }
        return phases[index + 1].title
    }

    var specialPhases: [BattleTurnPhase] {
        let phases = Set(allAbilities.flatMap(\.phases))
        return [BattleTurnPhase.enemyMovement, .endOfAnyTurn]
            .filter { phases.contains($0) }
    }

    func setAttacker(isPlayerOne: Bool?) {
        matchState.attackerIsPlayerOne = isPlayerOne
        MatchSetupStore.save(matchState)
        onMatchStateChange?()
        objectWillChange.send()
    }

    func resetTracker() {
        trackerState = BattleTrackerState(
            activePlayerIsOne: trackerState.activePlayerIsOne,
            currentPhase: playContext.playEngine.initialPhase()
        )
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
        refreshAbilities()
    }

    var activePlayerIsAttacker: Bool {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else { return false }
        return trackerState.activePlayerIsOne == attackerIsPlayerOne
    }

    func playerIsAttacker(isOne: Bool) -> Bool {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else { return false }
        return isOne == attackerIsPlayerOne
    }

    var attackerIsPlayerOne: Bool? {
        matchState.attackerIsPlayerOne
    }

    func persist() {
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
    }

    func isActivePlayerArmy(_ armyId: String) -> Bool {
        let activeArmyId = trackerState.activePlayerIsOne ? playerOneArmy?.id : playerTwoArmy?.id
        return armyId == activeArmyId
    }
}
