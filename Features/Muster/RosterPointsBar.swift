import SwiftUI
import TabletomeHobbyData

struct RosterPointsBar: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let roster: Roster
    private var total: Int { RosterPoints.total(roster.orderedEntries) }
    private var limit: Int { RosterPoints.limit(for: roster) }
    private var remaining: Int { RosterPoints.remaining(for: roster) }
    private var over: Bool { RosterPoints.isOverLimit(roster) }
    private var largeText: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        VStack(spacing: largeText ? 10 : 8) {
            ProgressView(value: RosterPoints.fillFraction(roster))
                .tint(over ? .red : .accentColor)
            if largeText {
                VStack(alignment: .leading, spacing: 6) {
                    pointsPrimaryLine
                    if limit > 0 { pointsSecondaryLine }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                pointsSummary
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.bar)
        .overlay(alignment: .top) {
            if over {
                Rectangle()
                    .fill(Color.red.opacity(0.45))
                    .frame(height: 2)
            }
        }
        .accessibilityIdentifier("rosterPointsBar")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var pointsPrimaryLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(total)")
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(over ? Color.red : Color.accentOnSurface)
            Text(String(localized: "pts used"))
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var pointsSecondaryLine: some View {
        if over {
            Text(String(localized: "of \(limit), \(-remaining) over limit"))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(String(localized: "of \(limit), \(remaining) remaining"))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var pointsSummary: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(total)")
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(over ? Color.red : Color.accentOnSurface)
            Text(String(localized: "pts used"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if limit > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(localized: "of \(limit)"))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(over ? .red : .secondary)
                    if !over {
                        Text(String(localized: "\(remaining) left"))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "\(-remaining) over"))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private var accessibilitySummary: String {
        guard limit > 0 else { return String(localized: "Points \(total), no limit") }
        if over {
            return String(localized: "Points \(total) of \(limit), over limit by \(-remaining)")
        }
        return String(localized: "Points \(total) of \(limit), \(remaining) remaining")
    }
}
