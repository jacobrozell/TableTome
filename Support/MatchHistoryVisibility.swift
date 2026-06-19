import Foundation
import TabletomeDomain

/// Gates Match History toolbar links until the user has at least one saved match.
enum MatchHistoryVisibility: Sendable {
    static func showsToolbar(repository: any MatchHistoryRepository) async -> Bool {
        guard ReleaseSurface.showsMatchHistory else { return false }
        let records = (try? await repository.fetchRecords(limit: 1, gameSystemId: nil)) ?? []
        return !records.isEmpty
    }
}
