#if DEBUG
import SwiftUI

struct TTComponentGallery: View {
    @State private var score = 4
    @State private var segment = GallerySegment.play

    var body: some View {
        List {
            Section { TTBadge("Active", tone: .playerOne, style: .solid); TTBadge("Destroyed", tone: .danger) } header: { TTSectionHeader("Badge") }
            Section { TTIconTile(systemImage: "book.closed") } header: { TTSectionHeader("Icon") }
            Section { TTRow(title: "Spearhead", subtitle: "Starter box", systemImage: "shield.lefthalf.filled") } header: { TTSectionHeader("Row") }
            Section { TTCounter(value: $score, range: 0...20, label: "Score") } header: { TTSectionHeader("Counter") }
            Section { TTProgressBar(fraction: 0.4, tone: .brand).frame(height: 8) } header: { TTSectionHeader("Progress") }
            Section {
                TTSegmentedControl(selection: $segment, options: GallerySegment.allCases, title: \.title)
            } header: { TTSectionHeader("Segment") }
            Section {
                TTEmptyState(title: "No matches yet", message: "Finish a battle and it shows up here.", systemImage: "flag.checkered")
            } header: { TTSectionHeader("Empty") }
        }
        .ttGroupedList()
        .navigationTitle("Design System")
        .textCase(nil)
    }
}

private enum GallerySegment: String, CaseIterable, Identifiable {
    case play, rules
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}
#endif
