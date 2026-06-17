import Foundation

public enum WarscrollSheetCatalog: Sendable {
    public static func sheetImageURL(
        armyId: String,
        unitId: String,
        bundle: Bundle = .main
    ) -> URL? {
        guard !armyId.isEmpty, !unitId.isEmpty else { return nil }

        let subdirectories = [
            "Rules/Warscrolls/\(armyId)",
            "Warscrolls/\(armyId)"
        ]
        for subdirectory in subdirectories {
            if let url = bundle.url(forResource: unitId, withExtension: "png", subdirectory: subdirectory) {
                return url
            }
        }
        return nil
    }

    public static func hasSheetImage(
        armyId: String,
        unitId: String,
        bundle: Bundle = .main
    ) -> Bool {
        sheetImageURL(armyId: armyId, unitId: unitId, bundle: bundle) != nil
    }
}
