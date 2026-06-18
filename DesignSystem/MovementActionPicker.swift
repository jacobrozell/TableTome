import SwiftUI

enum MovementAction: String, CaseIterable, Identifiable {
    case normal
    case run

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal: String(localized: "Normal Move")
        case .run: String(localized: "Run")
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
        }
    }
}

struct MovementActionPicker: View {
    @Binding var action: MovementAction

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Movement type"))
                .font(.subheadline.weight(.semibold))

            Picker(String(localized: "Movement type"), selection: $action) {
                ForEach(MovementAction.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.movementAction")

            Text(action.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.movementActionCard")
    }
}
