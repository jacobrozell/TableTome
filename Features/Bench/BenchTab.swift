import SwiftUI
import TabletomeHobbyData

/// Bench pillar — MiniMuster Collection + Paints merged into one tab.
struct BenchTab: View {
  @Environment(AppRouter.self) private var router
  @State private var section: BenchSection = .collection

  enum BenchSection: String, CaseIterable, Identifiable {
    case collection
    case paints

    var id: String { rawValue }

    var label: String {
      switch self {
      case .collection: String(localized: "Collection")
      case .paints: String(localized: "Paints")
      }
    }

    var icon: String {
      switch self {
      case .collection: "shield.lefthalf.filled"
      case .paints: "paintpalette.fill"
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      Picker("Bench section", selection: $section) {
        ForEach(BenchSection.allCases) { item in
          Label(item.label, systemImage: item.icon).tag(item)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal, DesignTokens.Spacing.md)
      .padding(.vertical, DesignTokens.Spacing.sm)
      .accessibilityIdentifier("bench.sectionPicker")

      Group {
        switch section {
        case .collection:
          CollectionTab()
        case .paints:
          PaintsTab()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .onAppear { syncSectionFromRouter() }
    .onChange(of: router.tab) { _, _ in syncSectionFromRouter() }
    .onChange(of: section) { _, newValue in
      switch newValue {
      case .collection: router.tab = .armies
      case .paints: router.tab = .paints
      }
    }
    .accessibilityIdentifier("bench.root")
  }

  private func syncSectionFromRouter() {
    switch router.tab {
    case .armies: section = .collection
    case .paints: section = .paints
    case .muster: break
    }
  }
}
