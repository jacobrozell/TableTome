# Tabletome

Offline-first iOS reference and rules companion for Warhammer tabletop games, starting with **Age of Sigmar: Spearhead**.

## Build & Run

**Requirements:** Xcode 16+, iOS 17+ simulator or device.

```bash
# Generate Xcode project (not committed — see .gitignore)
xcodegen generate

# Build
xcodebuild build \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -quiet

# Unit tests
xcodebuild test \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -quiet
```

## Product & Architecture

- **Brainstorm (non-authoritative):** [docs/brainstorm.md](docs/brainstorm.md)
- **System specs:** [specs/README.md](specs/README.md)
- **Feature inventory:** [docs/feature-inventory.md](docs/feature-inventory.md)
- **Agent build checklist:** [docs/agent-build-checklist.md](docs/agent-build-checklist.md)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)

## Data

Bundled JSON under `Resources/Rules/` powers offline reference content. See [specs/DataSchemaSpec.md](specs/DataSchemaSpec.md).

## Agent Tooling

XcodeBuildMCP and iOS Simulator MCP are configured in [`.cursor/mcp.json`](.cursor/mcp.json).
