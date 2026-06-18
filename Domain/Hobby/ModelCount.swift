import Foundation

/// Ported from MiniMuster `Domain/ModelCount.swift`. Estimates physical model count
/// for a unit entry by summing integers inside the first `(...)` group, times qty.
public enum ModelCount {
    public static func of(name: String, qty: Int) -> Int {
        let q = max(1, qty)
        guard let inner = firstParenGroup(name) else { return q }
        let nums = inner.matches(of: /\d+/).compactMap { Int($0.output) }
        guard !nums.isEmpty else { return q }
        return nums.reduce(0, +) * q
    }

    public static func firstParenGroup(_ name: String) -> Substring? {
        guard let open = name.firstIndex(of: "(") else { return nil }
        let afterOpen = name.index(after: open)
        guard let close = name[afterOpen...].firstIndex(of: ")") else { return nil }
        return name[afterOpen..<close]
    }
}
