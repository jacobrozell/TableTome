import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

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

    private var progressTitle: String {
        scoped
            ? String(localized: "Filtered progress")
            : String(localized: "Collection progress")
    }

    private var accessibilityProgressLabel: String {
        scoped
            ? String(localized: "Filtered progress, \(overall) percent")
            : String(localized: "Collection progress, \(overall) percent")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    ProgressRing(percent: overall, diameter: 88)
                    Text(progressTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(localized: "\(overall)% complete"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityProgressLabel)

                VStack(alignment: .leading, spacing: 6) {
                    ProgressMeter(segments: Pipeline.segments(of: scopedUnits, resolvedGlobal), height: 10)
                    ProgressLegend(segments: Pipeline.segments(of: scopedUnits, resolvedGlobal))
                }
                .padding(.horizontal)

                ArmyStatsHeader(units: scopedUnits,
                                armyCount: scoped ? visible.count : armies.count,
                                pipeline: resolvedGlobal, scoped: scoped)

                if scoped {
                    Button(String(localized: "Advance visible units"), systemImage: "arrow.right.to.line") {
                        let n = ArmyStore.advanceUnits(visible.flatMap(\.units), global: globalPipeline, in: context)
                        if n > 0 {
                            banner.show(String(localized: "Advanced \(n) unit\(n == 1 ? "" : "s")"))
                        } else {
                            banner.show(String(localized: "Nothing to advance"))
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button(String(localized: "Clear filters"), systemImage: "line.3.horizontal.decrease.circle") {
                        ArmyFilter.clearFilters(cfg)
                        try? context.save()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "Overview"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
