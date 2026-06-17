# Tech Stack Spec

## Platform

| Setting | Value |
|---------|-------|
| Min iOS | 17.0 |
| Swift | 6.0 |
| UI | SwiftUI |
| Persistence (v1) | UserDefaults for preferences; rules in bundled JSON |
| Persistence (future) | SwiftData for bookmarks, battle history |

## Tooling

| Tool | Purpose |
|------|---------|
| XcodeGen | `project.yml` → `.xcodeproj` (gitignored) |
| SwiftLint | Style + CI pre-build |
| xcodebuild | CI build/test (`SpearheadCI` scheme) |
| XcodeBuildMCP | Agent builds (`.cursor/mcp.json`) |

## Third-Party SDKs (v1)

None. No analytics SDK in v0.1.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `project.yml`, `README.md` |
