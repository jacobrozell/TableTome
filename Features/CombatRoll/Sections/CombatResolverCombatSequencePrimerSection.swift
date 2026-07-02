import SwiftUI
import TabletomeDomain

struct CombatResolverCombatSequencePrimerSection: View {
    @Binding var isExpanded: Bool
    let gameSystemId: String

    var body: some View {
        CombatSequencePrimer(
            isExpanded: $isExpanded,
            gameSystemId: gameSystemId,
            showsDismissButton: !NewPlayerTipsStore.hasDismissedCombatSequencePrimer,
            onDismiss: {
                NewPlayerTipsStore.dismissCombatSequencePrimer()
            }
        )
    }
}
