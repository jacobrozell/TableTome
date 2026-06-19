import Foundation

public enum AppLinks {
    /// Published via GitHub Pages from the `docs/` folder.
    /// Enable: repo Settings → Pages → Deploy from branch `main` / `docs`.
    private static let pagesBase = URL(string: "https://jacobrozell.github.io/Tabletome")!

    public static let privacy = pagesBase.appending(path: "privacy.html")
    public static let support = pagesBase.appending(path: "support.html")
    public static let accessibility = pagesBase.appending(path: "accessibility.html")
    public static let sourceRepository = URL(string: "https://github.com/jacobrozell/Tabletome")!
}
