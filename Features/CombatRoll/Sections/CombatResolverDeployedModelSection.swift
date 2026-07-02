import SwiftUI
import TabletomeDomain

struct CombatResolverDeployedModelSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    let onSyncMultiAttack: () -> Void

    var body: some View {
        if viewModel.selectedAttackerUnit != nil, viewModel.selectedAttackerWeapon != nil {
            DeployedModelCountStepper(
                modelCount: $viewModel.attackerDeployedModelCount,
                warscrollModelCount: viewModel.selectedAttackerUnit?.modelCount,
                usesVariableAttacks: viewModel.attackerUsesVariableAttacks,
                onChange: onSyncMultiAttack,
                accessibilityPrefix: accessibilityPrefix
            )
        }
    }
}
