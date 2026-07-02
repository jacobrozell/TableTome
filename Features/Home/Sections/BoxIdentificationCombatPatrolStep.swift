import SwiftUI

struct BoxIdentificationCombatPatrolStep: View {
    let onSelectCombatPatrol: () -> Void
    let onSelectDifferentFormat: () -> Void

    var body: some View {
        Section {
            Button(String(localized: "Yes — Combat Patrol on the cover")) {
                onSelectCombatPatrol()
            }
            Button(String(localized: "No — different starter format")) {
                onSelectDifferentFormat()
            }
        } header: {
            Text(String(localized: "Does the box say Combat Patrol?"))
        } footer: {
            Text(String(localized: "Combat Patrol is a 10th Edition starter format — small two-player box with missions inside."))
        }
    }
}
