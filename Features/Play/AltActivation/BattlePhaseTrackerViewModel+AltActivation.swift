import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    var focusedScTmgDeploymentStep: ScTmgDeploymentChecklistStep? {
        guard playContext.capabilities.showsActivationBar, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteScTmgSetupStep(in: trackerState.completedDeploymentSteps)
    }

    var scFirstPlayerMarkerHolderName: String? {
        guard let markerIsOne = trackerState.scFirstPlayerMarkerIsPlayerOne else { return nil }
        return markerIsOne ? playerOneName : playerTwoName
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

    func passActivation() {
        trackerEngine.passActivation(trackerState: &trackerState)
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }
}
