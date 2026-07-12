#!/usr/bin/env bash
#
# run-uitests.sh — run the XCUITest suite (defaults to the keypad interaction tests).
#
# Usage:
#   ./run-uitests.sh [selector]
#
#   selector   which tests to run, relative to the AlineaTake-HomeUITests target:
#                (default)  AmountEntryInteractionUITests  — drives the keypad
#                <Class>            e.g. VoiceOverLocalizationUITests
#                <Class>/<method>   e.g. AmountEntryInteractionUITests/testDeleteRemovesLastDigitAndReturnsToPlaceholder
#                all                the whole UI-test target
#
# Examples:
#   ./run-uitests.sh
#   ./run-uitests.sh AmountEntryInteractionUITests/testSelectingAChipSetsTheAmount
#   ./run-uitests.sh all
#
# Env overrides:
#   SIM       simulator name or UDID (default: "iPhone 17 Pro")
#   SCHEME    Xcode scheme           (default: AlineaTake-Home)
#   PROJECT   .xcodeproj path        (default: AlineaTake-Home.xcodeproj)
#   UITARGET  UI-test target name    (default: AlineaTake-HomeUITests)

set -euo pipefail

SIM="${SIM:-iPhone 17 Pro}"
SCHEME="${SCHEME:-AlineaTake-Home}"
PROJECT="${PROJECT:-AlineaTake-Home.xcodeproj}"
UITARGET="${UITARGET:-AlineaTake-HomeUITests}"

selector="${1:-AmountEntryInteractionUITests}"

# Run this script from the repo root so the relative project path resolves.
cd "$(dirname "$0")"

# A UDID (8-4-4-4-12 hex) selects the sim by id; anything else by name.
if [[ "$SIM" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}- ]]; then
  destination="id=$SIM"
else
  destination="platform=iOS Simulator,name=$SIM"
fi

# Boot the simulator if needed (no-op if already booted).
xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1 || xcrun simctl boot "$SIM" >/dev/null 2>&1 || true

if [ "$selector" = "all" ]; then
  only_testing="$UITARGET"
else
  only_testing="$UITARGET/$selector"
fi

echo "Running $only_testing on '$SIM'…"
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$destination" \
  -only-testing:"$only_testing"
