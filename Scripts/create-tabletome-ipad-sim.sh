#!/usr/bin/env bash
set -euo pipefail

NAME="TableTome iPad"
DEVICE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPad-Pro-11-inch-M4-8GB"
RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-26-5"

existing="$(xcrun simctl list devices available | rg "$NAME \(" || true)"
if [[ -n "$existing" ]]; then
  echo "Simulator already exists: $existing"
  exit 0
fi

uuid="$(xcrun simctl create "$NAME" "$DEVICE_TYPE" "$RUNTIME")"
echo "Created $NAME ($uuid)"
