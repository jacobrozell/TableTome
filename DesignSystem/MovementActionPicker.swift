import SwiftUI
import TabletomeDomain

enum MovementAction: String, CaseIterable, Identifiable {
    case normal
    case run
    case retreat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal: String(localized: "Normal Move")
        case .run: String(localized: "Run")
        case .retreat: String(localized: "Retreat")
        }
    }

    var detail: String {
        switch self {
        case .normal:
            String(localized: "Move up to the unit's Move characteristic.")
        case .run:
            String(
                localized: "Add extra distance this phase, but the unit usually cannot shoot or charge afterward."
            )
        case .retreat:
            String(
                localized: """
                In combat: roll D3 mortal wounds on the unit, then move up to Move. Cannot end in enemy combat range. \
                No Shoot or Charge this turn.
                """
            )
        }
    }
}

struct MovementActionPicker: View {
    @Binding var action: MovementAction
    var gameSystemId: String = GameSystemId.aosSpearhead.rawValue

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Movement type"))
                .font(.subheadline.weight(.semibold))

            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    Picker(String(localized: "Movement type"), selection: $action) {
                        ForEach(MovementAction.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    Picker(String(localized: "Movement type"), selection: $action) {
                        ForEach(MovementAction.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .accessibilityIdentifier("battleTracker.movementAction")

            Text(action.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if action == .retreat,
               let retreatEntry = SpearheadRulesGlossary.entries.first(where: { $0.id == "retreat" }) {
                GlossaryChip(entry: retreatEntry, gameSystemId: gameSystemId)
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.movementActionCard")
    }
}
