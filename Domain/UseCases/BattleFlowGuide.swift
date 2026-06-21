import Foundation

public struct BattleFlowGuideStep: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case deployment(DeploymentChecklistStep)
        case scSetup(ScTmgDeploymentChecklistStep)
        case wh40kSetup(Wh40kDeploymentChecklistStep)
        case cpSetup(CombatPatrolDeploymentChecklistStep)
        case roundOpener(BattleRoundChecklistStep)
        case turnPhase(BattleTurnPhase)
        case startNextRound(Int)
        case battleComplete
    }

    public let kind: Kind
    public let title: String
    public let instruction: String
    public let actionLabel: String

    public init(kind: Kind, title: String, instruction: String, actionLabel: String) {
        self.kind = kind
        self.title = title
        self.instruction = instruction
        self.actionLabel = actionLabel
    }
}

public enum BattleFlowGuide {
    public static func currentStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        gameSystemId: GameSystemId
    ) -> BattleFlowGuideStep? {
        currentStep(matchState: matchState, trackerState: trackerState, gameSystemId: gameSystemId.rawValue)
    }

    public static func currentStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        gameSystemId: String = GameSystemId.default.rawValue
    ) -> BattleFlowGuideStep? {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isStarCraft {
            return starCraftStep(matchState: matchState, trackerState: trackerState)
        }

        if context.isCombatPatrol {
            return combatPatrolStep(matchState: matchState, trackerState: trackerState, gameSystemId: gameSystemId)
        }

        if context.isWh40k {
            return wh40kStep(matchState: matchState, trackerState: trackerState, gameSystemId: gameSystemId)
        }

        if trackerState.battleRound == 1,
           let deploymentStep = nextIncompleteDeploymentStep(in: trackerState.completedDeploymentSteps) {
            return deploymentGuide(for: deploymentStep, matchState: matchState)
        }

        let round = trackerState.battleRound
        if let openerStep = nextIncompleteRoundOpenerStep(
            round: round,
            completedSteps: trackerState.completedRoundChecklistSteps
        ) {
            return roundOpenerGuide(for: openerStep, round: round, matchState: matchState)
        }

        let roundCount = BattleRules.battleRoundCount(gameSystemId: gameSystemId)
        if trackerState.currentPhase == .endOfTurn {
            if round >= roundCount {
                return battleCompleteStep(roundCount: roundCount)
            }
            return endOfTurnHandoffStep()
        }

        return turnPhaseGuide(
            phase: trackerState.currentPhase,
            round: round,
            activePlayerIsOne: trackerState.activePlayerIsOne,
            matchState: matchState,
            gameSystemId: gameSystemId
        )
    }

    private static func combatPatrolStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        gameSystemId: String
    ) -> BattleFlowGuideStep? {
        if trackerState.battleRound == 1,
           let step = nextIncompleteCombatPatrolSetupStep(in: trackerState.completedDeploymentSteps) {
            return cpSetupGuide(for: step)
        }

        let round = trackerState.battleRound
        let roundCount = BattleRules.battleRoundCount(gameSystemId: gameSystemId)
        if trackerState.currentPhase == .endOfTurn {
            if round >= roundCount {
                return battleCompleteStep(roundCount: roundCount)
            }
            return cpEndOfTurnHandoffStep(matchState: matchState, trackerState: trackerState, round: round)
        }

        return turnPhaseGuide(
            phase: trackerState.currentPhase,
            round: round,
            activePlayerIsOne: trackerState.activePlayerIsOne,
            matchState: matchState,
            gameSystemId: gameSystemId
        )
    }

    public static func nextIncompleteCombatPatrolSetupStep(
        in completedSteps: Set<String>
    ) -> CombatPatrolDeploymentChecklistStep? {
        CombatPatrolDeploymentChecklistStep.allCases.first {
            !CombatPatrolDeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps)
        }
    }

    private static func cpSetupGuide(for step: CombatPatrolDeploymentChecklistStep) -> BattleFlowGuideStep {
        BattleFlowGuideStep(
            kind: .cpSetup(step),
            title: step.title,
            instruction: step.detail,
            actionLabel: String(localized: "Done — Next Step")
        )
    }

    private static func cpEndOfTurnHandoffStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        round: Int
    ) -> BattleFlowGuideStep {
        let activeIsFirstTurn = matchState.firstTurnIsPlayerOne == trackerState.activePlayerIsOne
        let roundFiveNote = round == CombatPatrolBattleRules.battleRoundCount && !activeIsFirstTurn
            ? String(localized: " Round 5: score primary VP now (second-turn player scores at end of turn).")
            : ""
        return BattleFlowGuideStep(
            kind: .turnPhase(.endOfTurn),
            title: String(localized: "End of Turn"),
            instruction: String(
                localized: """
                Score secondaries and any end-of-turn objectives, then pass the turn. \
                Apply Battle Ready (+10 VP) when the battle ends if agreed.\(roundFiveNote)
                """
            ),
            actionLabel: String(localized: "Next Player's Turn")
        )
    }

    private static func wh40kStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState,
        gameSystemId: String
    ) -> BattleFlowGuideStep? {
        if trackerState.battleRound == 1,
           let step = nextIncompleteWh40kSetupStep(in: trackerState.completedDeploymentSteps) {
            return wh40kSetupGuide(for: step)
        }

        let round = trackerState.battleRound
        let roundCount = BattleRules.battleRoundCount(gameSystemId: gameSystemId)
        if trackerState.currentPhase == .endOfTurn {
            if round >= roundCount {
                return battleCompleteStep(roundCount: roundCount)
            }
            return wh40kEndOfTurnHandoffStep(gameSystemId: gameSystemId)
        }

        return turnPhaseGuide(
            phase: trackerState.currentPhase,
            round: round,
            activePlayerIsOne: trackerState.activePlayerIsOne,
            matchState: matchState,
            gameSystemId: gameSystemId
        )
    }

    public static func nextIncompleteWh40kSetupStep(in completedSteps: Set<String>) -> Wh40kDeploymentChecklistStep? {
        Wh40kDeploymentChecklistStep.allCases.first {
            !Wh40kDeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps)
        }
    }

    private static func wh40kSetupGuide(for step: Wh40kDeploymentChecklistStep) -> BattleFlowGuideStep {
        BattleFlowGuideStep(
            kind: .wh40kSetup(step),
            title: step.title,
            instruction: step.detail,
            actionLabel: String(localized: "Done — Next Step")
        )
    }

    private static func wh40kEndOfTurnHandoffStep(gameSystemId: String) -> BattleFlowGuideStep {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        let instruction = context.isWh40k11e
            ? String(
                localized: """
                Score primary and secondary objectives, remove models from out-of-coherency units, then pass the turn. \
                Both players gain 1 Core Command Point at the start of the next Command phase.
                """
            )
            : String(
                localized: """
                Score primary and secondary objectives, resolve end-of-turn abilities, then pass the turn. \
                Command Points refresh at the start of each player's next Command phase.
                """
            )
        return BattleFlowGuideStep(
            kind: .turnPhase(.endOfTurn),
            title: String(localized: "End of Turn"),
            instruction: instruction,
            actionLabel: String(localized: "Next Player's Turn")
        )
    }

    private static func starCraftStep(
        matchState: GuidedMatchState,
        trackerState: BattleTrackerState
    ) -> BattleFlowGuideStep? {
        if trackerState.battleRound == 1,
           let step = nextIncompleteScTmgSetupStep(in: trackerState.completedDeploymentSteps) {
            return scSetupGuide(for: step)
        }

        let round = trackerState.battleRound
        if trackerState.currentPhase == .scoring {
            if round >= ScTmgBattleRules.battleRoundCount {
                return battleCompleteStep(roundCount: ScTmgBattleRules.battleRoundCount)
            }
            return BattleFlowGuideStep(
                kind: .turnPhase(.scoring),
                title: String(localized: "Round \(round) — Scoring"),
                instruction: String(
                    localized: """
                    Score mission victory points. Objectives use total Supply within 3\" — not model count. \
                    Then start the next battle round at Movement and bump each player's supply pool.
                    """
                ),
                actionLabel: String(localized: "Next Round")
            )
        }

        return turnPhaseGuide(
            phase: trackerState.currentPhase,
            round: round,
            activePlayerIsOne: trackerState.activePlayerIsOne,
            matchState: matchState,
            gameSystemId: "sc-tmg"
        )
    }

    public static func nextIncompleteScTmgSetupStep(in completedSteps: Set<String>) -> ScTmgDeploymentChecklistStep? {
        ScTmgDeploymentChecklistStep.allCases.first {
            !ScTmgDeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps)
        }
    }

    private static func battleCompleteStep(roundCount: Int) -> BattleFlowGuideStep {
        BattleFlowGuideStep(
            kind: .battleComplete,
            title: String(localized: "Battle Over"),
            instruction: String(
                localized: "All \(roundCount) battle rounds are complete. Total victory points to find the winner."
            ),
            actionLabel: String(localized: "See Results")
        )
    }

    private static func endOfTurnHandoffStep() -> BattleFlowGuideStep {
        BattleFlowGuideStep(
            kind: .turnPhase(.endOfTurn),
            title: String(localized: "End of Turn"),
            instruction: String(
                localized: """
                Score victory points and resolve end-of-turn abilities, then pass the turn. \
                Battle tactic hands refresh at the start of the next battle round — not after each turn.
                """
            ),
            actionLabel: String(localized: "Next Player's Turn")
        )
    }

    public static func nextIncompleteDeploymentStep(in completedSteps: Set<String>) -> DeploymentChecklistStep? {
        DeploymentChecklistStep.allCases.first { !DeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps) }
    }

    public static func nextIncompleteRoundOpenerStep(
        round: Int,
        completedSteps: [String: Set<String>]
    ) -> BattleRoundChecklistStep? {
        BattleRoundChecklistStep.steps(forRound: round).first {
            !BattleRoundChecklist.isComplete(step: $0, round: round, completedSteps: completedSteps)
        }
    }

    private static func scSetupGuide(for step: ScTmgDeploymentChecklistStep) -> BattleFlowGuideStep {
        BattleFlowGuideStep(
            kind: .scSetup(step),
            title: step.title,
            instruction: step.detail,
            actionLabel: String(localized: "Done — Next Step")
        )
    }

    private static func deploymentGuide(
        for step: DeploymentChecklistStep,
        matchState: GuidedMatchState
    ) -> BattleFlowGuideStep {
        let defenderName = defenderName(in: matchState)
        let extra: String
        switch step {
        case .chooseRealmSide:
            extra = String(
                localized: """
                \(defenderName) picks the battlefield pack and side. Agree on Fire and Jade, Sand and Bone, \
                or City of Ash, then tap a side or use the coin flip for a fair tie-break.
                """
            )
        case .setupTerrain:
            extra = String(
                localized: """
                You need two large and two small pieces — ruins, woods, hills, or whatever you own. \
                Place them before any models go on the board.
                """
            )
        case .placeObjectives:
            extra = String(
                localized: """
                Point out each objective to your opponent so you both know what you are fighting over. \
                Holding objectives is how most victory points are scored each turn.
                """
            )
        case .deployArmies:
            extra = String(
                localized: """
                Each realm side has a different deployment map on the board. Stay inside the shaded areas \
                and follow the defender-first, alternating order on the map.
                """
            )
        case .deploymentAbilities:
            extra = String(
                localized: """
                Read your Spearhead army sheet — abilities marked “Deployment Phase” happen now, \
                before the battle round begins. Mark any you use so you do not forget they are spent.
                """
            )
        }
        return BattleFlowGuideStep(
            kind: .deployment(step),
            title: step.title,
            instruction: "\(step.detail) \(extra)",
            actionLabel: String(localized: "Done — Next Step")
        )
    }

    private static func roundOpenerGuide(
        for step: BattleRoundChecklistStep,
        round: Int,
        matchState: GuidedMatchState
    ) -> BattleFlowGuideStep {
        let attackerName = attackerName(in: matchState)
        let extra: String
        switch step {
        case .firstTurnOrPriority:
            extra = round == 1
                ? String(localized: "\(attackerName) chooses who takes the first turn this round.")
                : String(
                    localized: """
                    Roll off for priority — the winner picks who goes first. \
                    Seizing initiative (going second) may block refreshing battle tactics unless you are the underdog by 5+ VP.
                    """
                )
        case .identifyUnderdog:
            extra = String(localized: "Compare victory points on the tracker below. The player with fewer points is the underdog.")
        case .drawTwistCard:
            extra = String(
                localized: """
                This deck comes from your battlefield pack — Fire & Jade, Sand & Bone, or City of Ash. \
                Match the deck to the side you are fighting on, not your army faction.
                """
            )
        case .drawBattleTactics:
            extra = round == 1
                ? String(
                    localized: """
                    Each player draws 3 cards from the top of their shuffled battle tactic deck. \
                    Round 1 has no mulligan — you keep what you draw. \
                    Open the Card Decks Guide if dealing cards is confusing.
                    """
                )
                : String(
                    localized: """
                    Each player grabs their own battle tactic deck from their army starter box. \
                    Discard unwanted cards face up, draw the same number from the top. \
                    Open the Card Decks Guide if the mulligan step is confusing.
                    """
                )
        case .startOfRoundAbilities:
            extra = String(
                localized: "Resolve any Start of Battle Round abilities before the first turn begins. The tracker lists any found in your army data."
            )
        }
        return BattleFlowGuideStep(
            kind: .roundOpener(step),
            title: step.title(round: round),
            instruction: "\(step.detail(round: round)) \(extra)",
            actionLabel: String(localized: "Done — Next Step")
        )
    }

    private static func turnPhaseGuide(
        phase: BattleTurnPhase,
        round: Int,
        activePlayerIsOne: Bool,
        matchState: GuidedMatchState,
        gameSystemId: String
    ) -> BattleFlowGuideStep {
        let playerName = activePlayerIsOne ? matchState.playerOne.playerName : matchState.playerTwo.playerName
        return BattleFlowGuideStep(
            kind: .turnPhase(phase),
            title: String(localized: "Round \(round) — \(playerName)"),
            instruction: phase.guidance(
                gameSystemId: gameSystemId,
                round: round,
                matchState: matchState,
                activePlayerIsOne: activePlayerIsOne
            ),
            actionLabel: phase.guideActionLabel(gameSystemId: gameSystemId)
        )
    }

    private static func defenderName(in matchState: GuidedMatchState) -> String {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else {
            return String(localized: "The defender")
        }
        return attackerIsPlayerOne ? matchState.playerTwo.playerName : matchState.playerOne.playerName
    }

    private static func attackerName(in matchState: GuidedMatchState) -> String {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else {
            return String(localized: "The attacker")
        }
        return attackerIsPlayerOne ? matchState.playerOne.playerName : matchState.playerTwo.playerName
    }
}

private extension BattleTurnPhase {
    func guidance(
        gameSystemId: String,
        round: Int = 1,
        matchState: GuidedMatchState = GuidedMatchState(),
        activePlayerIsOne: Bool = true
    ) -> String {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isStarCraft {
            return scGuidance
        }
        if context.isCombatPatrol {
            return cpGuidance(round: round, matchState: matchState, activePlayerIsOne: activePlayerIsOne)
        }
        if context.isWh40k {
            return wh40kGuidance(for: gameSystemId)
        }
        return defaultGuidance
    }

    func guideActionLabel(gameSystemId: String) -> String {
        if GameSystemPlayContext.context(for: gameSystemId).isStarCraft, self == .scoring {
            return String(localized: "Next Round")
        }
        switch self {
        case .endOfTurn:
            return String(localized: "Finish Turn")
        default:
            return String(localized: "Next Phase")
        }
    }

    private func wh40kGuidance(for gameSystemId: String) -> String {
        if GameSystemPlayContext.context(for: gameSystemId).isWh40k11e {
            return wh40k11eGuidance
        }
        return wh40k10eGuidance
    }

    private var wh40k11eGuidance: String {
        switch self {
        case .command:
            String(
                localized: """
                Both players gain 1 Core Command Point. The active player tests Battle-shock on units at or below \
                Half-strength, uses stratagems, draws secondary cards, then scores objectives at end of Command phase.
                """
            )
        case .movement:
            String(
                localized: """
                Move, Advance, or Fall Back — units must end in coherency. Reserves arrive from battle round 2. \
                Overwatch fires once at the end of this phase.
                """
            )
        case .shooting:
            String(
                localized: """
                Pick units to shoot. Cover is -1 BS when every target model has cover. Indirect Fire needs 6+ unless \
                your unit stayed still and a friendly unit can see the target (4+).
                """
            )
        case .charge:
            String(
                localized: """
                Roll 2D6 for charge distance, then pick target(s) within 12 inches you can reach. Engagement range is \
                2 inches horizontally and 5 inches vertically.
                """
            )
        case .combat:
            String(
                localized: """
                All pile-ins first, then alternate fights (you pick the first unit). After fights, consolidate up to \
                3 inches using Ongoing, Engaging, or Objective mode.
                """
            )
        case .endOfTurn:
            String(
                localized: """
                Score mission triggers, remove models from out-of-coherency units, then pass the phone.
                """
            )
        default:
            defaultGuidance
        }
    }

    private var wh40k10eGuidance: String {
        switch self {
        case .command:
            String(
                localized: """
                Gain Command Points, test Battle-shock on damaged units, use stratagems, then score objectives \
                that trigger at the end of the Command phase.
                """
            )
        case .movement:
            String(
                localized: """
                Move units up to their Move characteristic. Advance for extra distance but usually lose shooting \
                unless a rule says otherwise.
                """
            )
        case .shooting:
            String(
                localized: """
                Pick units to shoot with. Measure range, roll hit and wound tests, then saves and damage on datasheets.
                """
            )
        case .charge:
            String(
                localized: """
                Declare charges into engagement range. Roll 2D6 — both dice must reach the target.
                """
            )
        case .combat:
            String(
                localized: """
                Fight with units in engagement range. Alternate fighting attacks, then apply damage to the Army Health tracker.
                """
            )
        case .endOfTurn:
            String(
                localized: """
                Finish scoring for the turn, resolve end-of-turn abilities, then pass the phone to your opponent.
                """
            )
        default:
            defaultGuidance
        }
    }

    private func cpGuidance(round: Int, matchState: GuidedMatchState, activePlayerIsOne: Bool) -> String {
        let missionId = matchState.selectedMissionId ?? "clash-of-patrols"
        let reservesNote = round == 3
            ? String(localized: " Reserves must arrive by end of this battle round or are destroyed.")
            : ""
        let scoringNote = CombatPatrolBattleRules.primaryScoringActive(round: round)
            ? String(localized: " Secure objectives with Battleline units, then score primary VP at end of Command phase.")
            : ""
        let activeIsFirstTurn = matchState.firstTurnIsPlayerOne == activePlayerIsOne
        let roundFiveNote = CombatPatrolBattleRules.scoresPrimaryAtEndOfTurn(
            round: round,
            activePlayerIsFirstTurnPlayer: activeIsFirstTurn
        )
            ? String(localized: " Score primary VP at end of turn, not Command phase.")
            : ""

        switch self {
        case .command:
            return String(
                localized: """
                Battle-shock tests, then secure objectives and mission actions.\(scoringNote)\(roundFiveNote)\(reservesNote) \
                Track stratagems on the Table State card.
                """
            )
        case .movement:
            return String(
                localized: """
                Move and Advance. Deep Strike and Reserves arrive in Movement from battle round 2.\(reservesNote)
                """
            )
        case .shooting, .charge, .combat:
            return wh40k10eGuidance
        case .endOfTurn:
            return String(
                localized: """
                Score secondaries and end-of-turn mission rules for \(missionLabel(missionId)). \
                Then pass the turn.
                """
            )
        default:
            return wh40k10eGuidance
        }
    }

    private func missionLabel(_ missionId: String) -> String {
        switch missionId {
        case "clash-of-patrols": String(localized: "Clash of Patrols")
        case "archeotech-recovery": String(localized: "Archeotech Recovery")
        case "forward-outpost": String(localized: "Forward Outpost")
        case "scorched-earth": String(localized: "Scorched Earth")
        case "sweeping-raid": String(localized: "Sweeping Raid")
        case "display-of-might": String(localized: "Display of Might")
        default: missionId
        }
    }

    private var scGuidance: String {
        switch self {
        case .movement:
            String(
                localized: """
                Alternate activations — one unit at a time. Deploy from reserves, then move. \
                Pass to claim the First Player Marker for Assault.
                """
            )
        case .assault:
            String(
                localized: """
                Alternate activations to shoot and charge. Counter matchups and Surge types matter. \
                Passing claims First Player Marker for Combat.
                """
            )
        case .combat:
            String(
                localized: """
                Resolve melee with alternating activations. Consolidate where allowed, then Pass when finished.
                """
            )
        case .scoring:
            String(
                localized: """
                Award mission victory points. Control objectives by Supply sum within 3\".
                """
            )
        default:
            String(
                localized: "Follow the phase flow on the Turn tab — alternating activations with Done and Pass."
            )
        }
    }

    private var defaultGuidance: String {
        switch self {
        case .deployment:
            String(localized: "Set up the battlefield and deploy armies before the first turn.")
        case .command:
            String(localized: "Gain Command points, use Stratagems, and resolve start-of-turn abilities.")
        case .hero:
            String(localized: "Use heroic abilities and command abilities. Cast spells and use prayers that trigger in the Hero phase.")
        case .movement:
            String(localized: "Move units that are allowed to move. Run if you need extra distance.")
        case .assault:
            String(localized: "Pick units to shoot with. Resolve hit, wound, save, and damage rolls.")
        case .shooting:
            String(localized: "Pick units to shoot with. Resolve hit, wound, save, and damage rolls.")
        case .charge:
            String(localized: "Declare charges into engagement range. Roll 2D6 for charge distance.")
        case .combat:
            String(localized: "Fight with units in combat. Pick targets, strike, and allocate damage.")
        case .scoring:
            String(localized: "Score victory points for mission objectives.")
        case .endOfTurn:
            String(localized: "Score victory points, resolve end-of-turn abilities, and pass the turn.")
        case .enemyMovement:
            String(localized: "Resolve abilities that trigger during enemy movement.")
        case .endOfAnyTurn:
            String(localized: "Resolve abilities that trigger at the end of any turn.")
        case .anyCombat:
            String(localized: "Resolve combat-phase reactions and abilities.")
        }
    }
}
