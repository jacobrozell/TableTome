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
                if trackerState.battleRound >= BattleRules.battleRoundCount(gameSystemId: gameSystemId) {
                    return
                }
                setBattleRound(trackerState.battleRound + 1)
                setPhase(ScTmgBattleRules.initialPhase)
            } else if phase == .endOfTurn {
                if trackerState.battleRound >= BattleRules.battleRoundCount(gameSystemId: gameSystemId) {
                    return
                }
                trackerState.activePlayerIsOne.toggle()
                trackerState.currentPhase = BattleRules.turnStartPhase(gameSystemId: gameSystemId)
                persist()
                refreshAbilities()
            } else {
                advancePhase()
            }
        case .startNextRound(let round):
            setBattleRound(round + 1)
            setPhase(BattleRules.turnStartPhase(gameSystemId: gameSystemId))
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

    func setScTmgDeploymentStep(_ step: ScTmgDeploymentChecklistStep, complete: Bool) {
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
