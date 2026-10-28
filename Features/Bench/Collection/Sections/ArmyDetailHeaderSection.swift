import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct ArmyDetailHeaderSection: View {
    let army: Army
    let pres: FactionPresentation
    let percent: Int
    let visibleUnits: [ArmyUnit]
    let pipeline: [PipelineStage]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var hasCustomPipeline: Bool {
        army.customPipeline?.isEmpty == false
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                identity
                ProgressMeter(segments: Pipeline.segments(of: visibleUnits, pipeline), height: 10)
                Text(String(localized: "\(percent)% complete"))
                    .font(TTFont.numericSmall)
                    .foregroundStyle(TTColor.inkSecondary)
                ArmyStatsHeader(
                    units: visibleUnits,
                    armyCount: 1,
                    pipeline: pipeline,
                    showsProgress: false
                )
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        }
    }

    @ViewBuilder
    private var identity: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                crest
                titles
            }
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                crest
                titles
            }
        }
    }

    private var crest: some View {
        CrestTile(
            text: pres.crest,
            colorHex: pres.colorHex,
            imageFileName: pres.imageFileName,
            side: 64
        )
    }

    private var titles: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(army.name)
                .font(TTFont.title)
                .foregroundStyle(TTColor.inkPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(SupportedGames.displayName(for: army.game)) · \(army.faction)")
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if hasCustomPipeline {
                TTBadge(String(localized: "Custom stages"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
