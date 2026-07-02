import SwiftUI

struct ArmyDetailBatchActionBar: View {
    let isEditing: Bool
    let selectionCount: Int
    let onAdvance: () -> Void
    let onDelete: () -> Void

    var body: some View {
        if isEditing, selectionCount > 0 {
            HStack(spacing: 12) {
                Text(String(localized: "\(selectionCount) selected"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(String(localized: "Advance")) { onAdvance() }
                    .buttonStyle(.borderedProminent)
                Button(String(localized: "Delete"), role: .destructive) { onDelete() }
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)
        }
    }
}
