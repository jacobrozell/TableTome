import Foundation

/// Ported from MiniMuster `Domain/Tags.swift`. `#tag` extraction from notes.
public enum Tags {
    public static func extract(_ notes: String) -> [String] {
        notes.matches(of: /#[\w-]+/).map {
            String($0.output.dropFirst()).lowercased()
        }
    }
}
