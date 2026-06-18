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
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        MatchVictoryScreen(
                            presentation: MatchVictoryPresentation(record: record),
                            mode: .readOnly
                        )

                        summarySection(record: record)
                        MatchLogTimelineView(events: logEvents)
                    }
                    .padding(.bottom, DesignTokens.Spacing.lg)
                }
                .background(Color(.systemGroupedBackground))
            } else if didFinishLoading {
                ContentUnavailableView {
                    Label(String(localized: "Match Not Found"), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(String(localized: "This match may have been deleted."))
                }
            } else {
                ProgressView()
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

    @ViewBuilder
    private func summarySection(record: MatchRecord) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Summary"), systemImage: "list.bullet.rectangle")
                .padding(.horizontal, DesignTokens.Spacing.md)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                summaryRow(
                    title: String(localized: "Battle round"),
                    value: "\(record.result.battleRound)"
                )
                if let missionId = record.setup.missionId {
                    summaryRow(
                        title: String(localized: "Mission"),
                        value: humanizeIdentifier(missionId)
                    )
                }
                summaryRow(
                    title: String(localized: "Played"),
                    value: record.endedAt.formatted(date: .complete, time: .shortened)
                )
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func humanizeIdentifier(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
