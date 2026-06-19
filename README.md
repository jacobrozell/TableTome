# Tabletome

Offline-first iOS reference and rules companion for Warhammer tabletop games, starting with **Age of Sigmar: Spearhead**.

## Build & Run

**Requirements:** Xcode 16+, iOS 17+ simulator or device.

```bash
# Generate Xcode project (not committed — see .gitignore)
xcodegen generate

# Build (dedicated Tabletome simulator — avoids clashing with other agents)
xcodebuild build \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet

# Unit tests
xcodebuild test \
  -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
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

**Dedicated simulator:** Run `Scripts/setup-tabletome-simulator.sh` to create or reuse a simulator named `Tabletome` (iPhone 17, iOS 26.4). Agents pin `IDB_UDID` in MCP config and use the `tabletome` XcodeBuildMCP profile so builds do not touch other projects' simulators.

**GitHub Pages:** Legal pages live in `docs/`. Enable **Settings → Pages → Deploy from branch `main` / `/docs`**. Published at `https://jacobrozell.github.io/Tabletome/`.

## Support

If Tabletome helps at your table, optional tips are appreciated: [Buy Me a Coffee](https://buymeacoffee.com/jacobrozelq).
