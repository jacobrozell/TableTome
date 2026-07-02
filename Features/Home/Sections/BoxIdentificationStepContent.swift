import SwiftUI
import TabletomeDomain

struct BoxIdentificationStepContent: View {
    let step: Int
    let sciFiBoxKind: BoxIdentificationSheet.SciFiBoxKind?
    let isCombatPatrolBox: Bool?
    let recommendedGameSystemId: String?
    let sciFiStarterFormat: BoxIdentificationSheet.SciFiStarterFormat?
    let visibleGenres: [BoxIdentificationSheet.Genre]
    let onSelectGenre: (BoxIdentificationSheet.Genre) -> Void
    let onSelectSciFiSize: (BoxIdentificationSheet.SciFiBoxKind) -> Void
    let onSelectStarterFormat: (BoxIdentificationSheet.SciFiStarterFormat) -> Void
    let onSelectCombatPatrol: () -> Void
    let onSelectDifferentFormat: () -> Void
    let onOpenGuide: () -> Void

    var body: some View {
        switch step {
        case 0:
            BoxIdentificationGenreStep(visibleGenres: visibleGenres, onSelect: onSelectGenre)
        case 1:
            BoxIdentificationSciFiSizeStep(onSelect: onSelectSciFiSize)
        case 2:
            if sciFiBoxKind == .starter {
                if ReleaseSurface.showsCombatPatrol, isCombatPatrolBox == nil {
                    BoxIdentificationCombatPatrolStep(
                        onSelectCombatPatrol: onSelectCombatPatrol,
                        onSelectDifferentFormat: onSelectDifferentFormat
                    )
                } else {
                    BoxIdentificationStarterFormatStep(onSelect: onSelectStarterFormat)
                }
            } else if let recommendedGameSystemId {
                BoxIdentificationResultStep(
                    recommendedGameSystemId: recommendedGameSystemId,
                    sciFiStarterFormat: sciFiStarterFormat,
                    sciFiBoxKind: sciFiBoxKind,
                    onOpenGuide: onOpenGuide
                )
            }
        default:
            if let recommendedGameSystemId {
                BoxIdentificationResultStep(
                    recommendedGameSystemId: recommendedGameSystemId,
                    sciFiStarterFormat: sciFiStarterFormat,
                    sciFiBoxKind: sciFiBoxKind,
                    onOpenGuide: onOpenGuide
                )
            }
        }
    }
}
