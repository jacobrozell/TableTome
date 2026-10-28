import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

/// Collection-wide progress hero used at the top of the Models list and on the overview screen.
struct CollectionOverviewHero: View {
    let percent: Int
    let armyCount: Int
    let unitCount: Int
    let segments: [ProgressSegment]
    let scoped: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var countsLine: String {
        let prefix = scoped ? String(localized: "Showing ") : ""
        return String(localized: "\(prefix)\(armyCount) armies · \(unitCount) units")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Your collection"))
                .ttEyebrow()

            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    ProgressRing(percent: percent, diameter: 88)
                    paintedLabel
                }
            } else {
                HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                    ProgressRing(percent: percent, diameter: 88)
                    paintedLabel
                    Spacer(minLength: 0)
                }
            }

            ProgressMeter(segments: segments, height: 10)
            ProgressLegend(segments: segments)
        }
        .surfaceCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityProgressLabel)
    }

    private var paintedLabel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(String(localized: "painted"))
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
            Text(countsLine)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var accessibilityProgressLabel: String {
        let progress = scoped
            ? String(localized: "Filtered progress, \(percent) percent painted")
            : String(localized: "Collection progress, \(percent) percent painted")
        return "\(progress). \(countsLine)"
    }
}

/// Collection-wide stats and progress (opened from toolbar).
@MainActor
struct CollectionOverviewView: View {
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner
    @Query(sort: \Army.sortIndex) private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    @Environment(AppRouter.self) private var router

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var search: String { router.collectionSearch }
    private var globalPipeline: [PipelineStage]? { cfg.globalPipeline }
    private var resolvedGlobal: [PipelineStage] { Pipeline.resolve(globalPipeline) }
    private var scoped: Bool { ArmyFilter.isActive(cfg, search: search) }
    private var visible: [VisibleArmy] {
        ArmyFilter.build(armies: armies, cfg: cfg, search: search, global: globalPipeline)
    }
    private var scopedUnits: [ArmyUnit] { scoped ? visible.flatMap(\.units) : armies.flatMap(\.units) }
    private var overall: Int {
        Int((Pipeline.progress(of: scopedUnits, resolvedGlobal) * 100).rounded())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                CollectionOverviewHero(
                    percent: overall,
                    armyCount: scoped ? visible.count : armies.count,
                    unitCount: scopedUnits.count,
                    segments: Pipeline.segments(of: scopedUnits, resolvedGlobal),
                    scoped: scoped
                )

                ArmyStatsHeader(
                    units: scopedUnits,
                    armyCount: scoped ? visible.count : armies.count,
                    pipeline: resolvedGlobal,
                    scoped: scoped,
                    showsProgress: false
                )
                .surfaceCard()

                if scoped {
                    Button(String(localized: "Advance visible units"), systemImage: "arrow.right.to.line") {
                        let n = ArmyStore.advanceUnits(visible.flatMap(\.units), global: globalPipeline, in: context)
                        if n > 0 {
                            banner.show(String(localized: "Advanced \(n) unit\(n == 1 ? "" : "s")"))
                        } else {
                            banner.show(String(localized: "Nothing to advance"))
                        }
                    }
                    .buttonStyle(.ttPrimary)

                    Button(String(localized: "Clear filters"), systemImage: "line.3.horizontal.decrease.circle") {
                        ArmyFilter.clearFilters(cfg)
                        try? context.save()
                    }
                    .buttonStyle(.ttSecondary)
                }
            }
            .padding(DesignTokens.Spacing.md)
            .readableContentWidth()
        }
        .background(TTColor.canvas.ignoresSafeArea())
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Overview"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
