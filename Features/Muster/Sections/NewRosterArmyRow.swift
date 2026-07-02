import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct NewRosterArmyRow: View {
    let army: Army
    let overrides: [FactionPresetOverride]

    var body: some View {
        let pres = army.presentation(overrides: overrides)
        HStack(spacing: 10) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(army.name)
                    .lineLimit(1)
                Text(army.faction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
