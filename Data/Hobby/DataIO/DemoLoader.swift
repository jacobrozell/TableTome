import Foundation
import SwiftData
import TabletomeDomain

/// Loads the bundled sample collection through the real import pipeline. Ports
/// `js/data/demo.js` (the web fetches the CSVs; we read them from the app bundle).
@MainActor
public enum DemoLoader {
    enum LoadError: Error { case missingResource }

    /// Replace the current collection + paints with the shipped samples.
    @discardableResult
    public static func load(into ctx: ModelContext) throws -> (armies: Int, paints: Int) {
        guard
            let armiesText = bundledCSV("warhammer_armies"),
            let paintsText = bundledCSV("warhammer_paint_inventory")
        else { throw LoadError.missingResource }

        let cfg = HobbyConfig.current(ctx)
        let pipeline = Pipeline.resolve(cfg.globalPipeline)

        let armyResult = ArmyCSV.import(CSV.parse(armiesText), pipeline: pipeline,
                                        overrides: cfg.factionOverrides)
        if let armies = armyResult.armies { CollectionStore.replaceArmies(armies, in: ctx) }

        let paintResult = PaintCSV.import(CSV.parse(paintsText))
        if let paints = paintResult.paints { CollectionStore.replacePaints(paints, in: ctx) }

        return (armyResult.stats["armies"] ?? 0, paintResult.stats["paints"] ?? 0)
    }

    public static func bundledCSV(_ name: String) -> String? {
        let url =
            Bundle.main.url(forResource: name, withExtension: "csv", subdirectory: "Catalogs")
            ?? Bundle.main.url(forResource: name, withExtension: "csv")
        guard let url, let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        return text
    }
}
