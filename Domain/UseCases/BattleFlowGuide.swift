import Foundation

public struct BattleFlowGuideStep: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case deployment(DeploymentChecklistStep)
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
        trackerState: BattleTrackerState
    ) -> BattleFlowGuideStep? {
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

        if trackerState.currentPhase == .endOfTurn {
            if round >= SpearheadBattleRules.battleRoundCount {
                return BattleFlowGuideStep(
                    kind: .battleComplete,
                    title: String(localized: "Battle Over"),
                    instruction: String(localized: "All four battle rounds are complete. Total up victory points to find the winner."),
                    actionLabel: String(localized: "Got it")
                )
            }
            return BattleFlowGuideStep(
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

        return turnPhaseGuide(
            phase: trackerState.currentPhase,
            round: round,
            activePlayerIsOne: trackerState.activePlayerIsOne,
            matchState: matchState
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
        matchState: GuidedMatchState
    ) -> BattleFlowGuideStep {
        let playerName = activePlayerIsOne ? matchState.playerOne.playerName : matchState.playerTwo.playerName
        return BattleFlowGuideStep(
            kind: .turnPhase(phase),
            title: String(localized: "Round \(round) — \(playerName)"),
            instruction: phase.guidance,
            actionLabel: phase.guideActionLabel
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
    var guidance: String {
        switch self {
        case .deployment:
            String(localized: "Set up the battlefield and deploy armies before the first turn.")
        case .hero:
            String(localized: "Use heroic abilities and command abilities. Cast spells and use prayers that trigger in the Hero phase.")
        case .movement:
            String(localized: "Move units that are allowed to move. Run if you need extra distance.")
        case .shooting:
            String(localized: "Pick units to shoot with. Resolve hit, wound, save, and damage rolls.")
        case .charge:
            String(localized: "Declare charges into engagement range. Roll 2D6 for charge distance.")
        case .combat:
            String(localized: "Fight with units in combat. Pick targets, strike, and allocate damage.")
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

    var guideActionLabel: String {
        switch self {
        case .endOfTurn:
            String(localized: "Finish Turn")
        default:
            String(localized: "Next Phase")
        }
    }
}
