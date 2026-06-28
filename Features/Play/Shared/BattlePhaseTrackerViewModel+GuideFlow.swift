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
            setRoundChecklistStep(openerStep, complete: true)
        case .turnPhase(let phase):
            if playContext.capabilities.showsActivationBar, phase == .scoring {
                if trackerState.battleRound >= playContext.playEngine.battleRoundCount() {
                    return
                }
                setBattleRound(trackerState.battleRound + 1)
                setPhase(playContext.playEngine.initialPhase())
            } else if phase == .endOfTurn {
                if trackerState.battleRound >= playContext.playEngine.battleRoundCount() {
                    return
                }
                trackerState.activePlayerIsOne.toggle()
                trackerState.currentPhase = playContext.playEngine.turnStartPhase()
                persist()
                refreshAbilities()
            } else {
                advancePhase()
            }
        case .startNextRound(let round):
            setBattleRound(round + 1)
            setPhase(playContext.playEngine.turnStartPhase())
        case .battleComplete:
            break
        }
    }

    func setDeploymentStep(_ step: DeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
            recordDeploymentStep(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func setWh40kDeploymentStep(_ step: Wh40kDeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
            recordDeploymentStep(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }
}
