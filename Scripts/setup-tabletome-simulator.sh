#!/usr/bin/env bash
# Creates (or reuses) a dedicated "Tabletome" iOS simulator for agent builds.
set -euo pipefail

SIM_NAME="Tabletome"
DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-17"
RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-4"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

existing="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS-26-4' not in runtime:
        continue
    for d in devices:
        if d.get('name') == '$SIM_NAME' and d.get('isAvailable', True):
            print(d['udid'])
            break
" 2>/dev/null || true)"

if [[ -n "$existing" ]]; then
  udid="$existing"
  echo "Reusing existing simulator: $SIM_NAME ($udid)"
else
  udid="$(xcrun simctl create "$SIM_NAME" "$DEVICE_TYPE" "$RUNTIME")"
  echo "Created simulator: $SIM_NAME ($udid)"
fi

echo ""
echo "Configure XcodeBuildMCP (run once per machine / after MCP restart):"
echo "  session_set_defaults with profile tabletome, simulatorId $udid, persist true"
echo ""
echo "ios-simulator MCP: set IDB_UDID=$udid in .cursor/mcp.json"
