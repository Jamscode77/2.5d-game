#!/usr/bin/env bash
# macOS / Linux: generate IDE project files.
# Set UE_ROOT to your Unreal Engine install, e.g. /Users/Shared/Epic\ Games/UE_5.5

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPROJECT="$ROOT/MechFrontline.uproject"

if [[ ! -f "$UPROJECT" ]]; then
  echo "Missing MechFrontline.uproject"
  exit 1
fi

if [[ -z "${UE_ROOT:-}" ]]; then
  echo "Set UE_ROOT to your Unreal Engine 5.5+ install path, then re-run."
  echo "Example: export UE_ROOT=/Users/Shared/Epic\\ Games/UE_5.5"
  exit 1
fi

UBT="$UE_ROOT/Engine/Build/BatchFiles/Linux/Build.sh"
if [[ "$(uname)" == "Darwin" ]]; then
  UBT="$UE_ROOT/Engine/Build/BatchFiles/Mac/Build.sh"
  # Prefer GenerateProjectFiles on Mac
  if [[ -x "$UE_ROOT/Engine/Build/BatchFiles/Mac/GenerateProjectFiles.sh" ]]; then
    "$UE_ROOT/Engine/Build/BatchFiles/Mac/GenerateProjectFiles.sh" -project="$UPROJECT" -game
    exit 0
  fi
fi

if [[ -x "$UE_ROOT/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh" ]]; then
  "$UE_ROOT/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh" -project="$UPROJECT" -game
  exit 0
fi

echo "Could not find GenerateProjectFiles under UE_ROOT=$UE_ROOT"
echo "Open MechFrontline.uproject from the Epic Launcher / Unreal Editor instead."
exit 1
