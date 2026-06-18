import SwiftUI
import TabletomeDomain

struct MatchLogTimelineView: View {
    let events: [MatchLogEvent]

    private struct TimelineSection: Identifiable {
        let id: String
        let title: String
        let events: [MatchLogEvent]
    }

    private var displayEvents: [MatchLogEvent] {
        var filtered: [MatchLogEvent] = []
        for (index, event) in events.enumerated() {
            if shouldHideDamageAfterBatch(event: event, at: index, in: events) {
                continue
            }
            filtered.append(event)
        }
        return filtered
    }

    private var groupedSections: [TimelineSection] {
        var sections: [TimelineSection] = []
        var currentTitle = ""
        var currentEvents: [MatchLogEvent] = []

        for event in displayEvents {
            let title = sectionTitle(for: event)
            if title != currentTitle, !currentEvents.isEmpty {
                sections.append(
                    TimelineSection(
                        id: "\(sections.count)-\(currentTitle)",
                        title: currentTitle,
                        events: currentEvents
                    )
                )
                currentEvents = []
            }
            currentTitle = title
            currentEvents.append(event)
        }
        if !currentEvents.isEmpty {
            sections.append(
                TimelineSection(
                    id: "\(sections.count)-\(currentTitle)",
                    title: currentTitle,
                    events: currentEvents
                )
            )
        }
        return sections
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                SectionHeader(title: String(localized: "Match Log"), systemImage: "text.book.closed")
                if !displayEvents.isEmpty {
                    Text("\(displayEvents.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)

            if displayEvents.isEmpty {
                Text(String(localized: "No events were recorded for this match."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
            } else {
                ForEach(groupedSections) { section in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(section.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, DesignTokens.Spacing.md)

                        ForEach(section.events) { event in
                            MatchLogEventRow(event: event)
                                .padding(.horizontal, DesignTokens.Spacing.md)
                                .accessibilityIdentifier("matchLog.event.\(event.id.uuidString)")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("matchLog.timeline")
    }

    private func shouldHideDamageAfterBatch(
        event: MatchLogEvent,
        at index: Int,
        in events: [MatchLogEvent]
    ) -> Bool {
        guard event.kind == .damageApplied, index > 0 else { return false }
        let previous = events[index - 1]
        guard previous.kind == .combatBatchResolved else { return false }
        guard event.payload.woundsRemoved == previous.payload.combatDamageDealt else { return false }
        let defender = previous.payload.defenderUnitName ?? ""
        let unit = event.payload.unitName ?? ""
        return !defender.isEmpty && defender == unit
    }

    private func sectionTitle(for event: MatchLogEvent) -> String {
        switch event.kind {
        case .matchStarted, .matchEnded:
            return String(localized: "Match")
        case .setupStepCompleted:
            return String(localized: "Setup")
        case .deploymentStepCompleted:
            return String(localized: "Deployment")
        default:
            if let round = event.payload.round {
                return String(localized: "Round \(round)")
            }
            return String(localized: "Battle")
        }
    }
}

private struct MatchLogEventRow: View {
    let event: MatchLogEvent

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: MatchLogSummaryFormatter.systemImage(for: event.kind))
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(MatchLogSummaryFormatter.title(for: event))
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = MatchLogSummaryFormatter.subtitle(for: event) {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(event.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .combine)
    }

    private var iconColor: Color {
        switch event.kind {
        case .victoryPointsChanged:
            .yellow
        case .damageApplied, .unitDestroyed:
            .red
        case .combatBatchResolved:
            .accentColor
        default:
            .accentColor
        }
    }
}
