import SwiftUI
import TabletomeDomain

struct MatchHistoryDetailView: View {
    let recordId: UUID
    @ObservedObject var viewModel: MatchHistoryViewModel

    @State private var record: MatchRecord?
    @State private var logEvents: [MatchLogEvent] = []
    @State private var didFinishLoading = false

    var body: some View {
        Group {
            if let record {
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        MatchVictoryScreen(
                            presentation: MatchVictoryPresentation(record: record),
                            mode: .readOnly
                        )

                        summaryCard(record: record)
                        MatchLogTimelineView(events: logEvents)
                    }
                    .readableContentWidth()
                    .padding(.top, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.lg)
                }
                .ttScreenBackground()
            } else if didFinishLoading {
                ScrollView {
                    TTEmptyState(
                        title: String(localized: "Match Not Found"),
                        message: String(localized: "This match may have been deleted."),
                        systemImage: "exclamationmark.triangle"
                    )
                    .padding(DesignTokens.Spacing.lg)
                    .readableContentWidth()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ttScreenBackground()
            } else {
                ProgressView(String(localized: "Loading match…"))
                    .asyncContentShell()
            }
        }
        .navigationTitle(record.map { MatchHistoryDisplayFormatter.matchupTitle(for: $0) } ?? String(localized: "Match Detail"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let record {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: MatchHistoryExportFormatter.text(record: record, events: logEvents),
                        subject: Text(MatchHistoryDisplayFormatter.matchupTitle(for: record)),
                        preview: SharePreview(
                            String(localized: "Match Summary"),
                            icon: Image(systemName: "flag.checkered")
                        )
                    ) {
                        Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("matchHistory.detail.share")
                }
            }
        }
        .accessibilityIdentifier("matchHistory.detail.\(recordId.uuidString)")
        .task {
            record = await viewModel.record(id: recordId)
            logEvents = await viewModel.log(matchId: recordId)
            didFinishLoading = true
        }
    }

    private func summaryCard(record: MatchRecord) -> some View {
        TTCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TTKeyValueRow(
                    String(localized: "Battle rounds"),
                    value: "\(record.result.battleRound)"
                )
                if let missionId = record.setup.missionId {
                    TTKeyValueRow(
                        String(localized: "Mission"),
                        value: humanizeIdentifier(missionId)
                    )
                }
                TTKeyValueRow(
                    String(localized: "Played"),
                    value: record.endedAt.formatted(date: .complete, time: .shortened)
                )
                TTKeyValueRow(
                    String(localized: "Duration"),
                    value: MatchDurationFormatter.label(for: record.duration)
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private func humanizeIdentifier(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
