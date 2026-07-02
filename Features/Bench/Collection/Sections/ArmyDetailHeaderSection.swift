import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailHeaderSection: View {
    let army: Army
    let pres: FactionPresentation
    let percent: Int
    let visibleUnits: [ArmyUnit]
    let pipeline: [PipelineStage]

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: HobbyGameSymbol.systemImage(for: army.game))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text("\(SupportedGames.displayName(for: army.game)) · \(army.faction)\(army.customPipeline?.isEmpty == false ? String(localized: " · custom pipeline") : "")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                    Spacer()
                    Text(String(localized: "\(percent)% complete"))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressMeter(segments: Pipeline.segments(of: visibleUnits, pipeline), height: 8)
            }
            .padding(.vertical, 4)
        }
    }
}
