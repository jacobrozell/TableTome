import SwiftUI
import TabletomeHobbyData

/// Bench pillar — MiniMuster Collection + Paints merged into one tab.
struct BenchTab: View {
  @Environment(AppRouter.self) private var router
  @State private var section: BenchSection = .collection

  enum BenchSection: String, CaseIterable, Identifiable, Hashable {
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

  private var visibleSections: [BenchSection] {
    if ReleaseSurface.showsPaintsInBench {
      return BenchSection.allCases
    }
    return [.collection]
  }

  var body: some View {
    VStack(spacing: 0) {
      if visibleSections.count > 1 {
        sectionPicker
      }

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

  /// Visual control is `TTSegmentedControl`. Clear buttons sit on top so the
  /// existing segment identifiers stay hittable for UI tests.
  private var sectionPicker: some View {
    ZStack {
      TTSegmentedControl(
        selection: $section,
        options: visibleSections,
        title: { $0.label },
        systemImage: { $0.icon }
      )
      .accessibilityHidden(true)
      .allowsHitTesting(false)

      HStack(spacing: DesignTokens.Spacing.xxs) {
        ForEach(visibleSections) { item in
          Button {
            section = item
          } label: {
            Text(item.label)
              .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
          }
          .buttonStyle(.plain)
          .foregroundStyle(.clear)
          .accessibilityIdentifier("bench.section.\(item.rawValue)")
          .accessibilityLabel(item.label)
          .accessibilityAddTraits(section == item ? .isSelected : [])
        }
      }
    }
    .padding(.horizontal, DesignTokens.Spacing.md)
    .padding(.vertical, DesignTokens.Spacing.sm)
    .background(TTColor.canvas)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("bench.sectionPicker")
    .accessibilityHint(String(localized: "Switch between your armies and paint inventory"))
  }

  private func syncSectionFromRouter() {
    switch router.tab {
    case .armies: section = .collection
    case .paints:
      section = ReleaseSurface.showsPaintsInBench ? .paints : .collection
    case .muster: break
    }
  }
}
