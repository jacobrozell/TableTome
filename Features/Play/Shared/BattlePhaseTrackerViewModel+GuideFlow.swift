import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func completeCurrentGuideStep() {
        guard let step = currentGuideStep else { return }
        switch step.kind {
        case .deployment(let deploymentStep):
            setDeploymentStep(deploymentStep, complete: true)
        case .scSetup(let setupStep):
            setScTmgDeploymentStep(setupStep, complete: true)
        case .wh40kSetup(let setupStep):
            setWh40kDeploymentStep(setupStep, complete: true)
        case .cpSetup(let setupStep):
            setCombatPatrolDeploymentStep(setupStep, complete: true)
        case .roundOpener(let openerStep):
            if openerStep == .firstTurnOrPriority, matchState.firstTurnIsPlayerOne == nil {
                return
            }
            setRoundChecklistStep(openerStep, complete: true)
        case .turnPhase(let phase):
            if playContext.usesAlternatingActivation {
                completeAlternatingActivationTurnPhase(phase)
            } else if phase == .endOfTurn, canAdvanceBattleRound {
                advanceBattleRound()
            } else {
                completePhasedRoundTurnPhase(phase)
            }
        case .startNextRound:
            advanceBattleRound()
        case .battleComplete:
            break
        }
    }
}
