#!/usr/bin/env bash
#
# test-locale.sh — launch the app in the simulator under a given locale + appearance.
#
# Usage:
#   ./test-locale.sh [locale] [appearance]
#
#   locale      en | ptBR | esMX | esES   (default: en)
#   appearance  light | dark (default: current — omit to leave unchanged)
#
# Examples:
#   ./test-locale.sh ptBR dark
#   ./test-locale.sh en light
#   ./test-locale.sh ptBR          # pt-BR, leave appearance as-is
#   ./test-locale.sh esMX          # Spanish copy + Mexican pesos (MXN)
#   ./test-locale.sh esES          # same Spanish copy + euros (EUR)
#
# Env overrides:
#   SIM     simulator UDID or name (default: "iPhone 17 Pro")
#   BUNDLE  app bundle id          (default: shadow.inc.AlineaTake-Home)

set -euo pipefail

SIM="${SIM:-iPhone 17 Pro}"
BUNDLE="${BUNDLE:-shadow.inc.AlineaTake-Home}"

locale_arg="${1:-en}"
appearance="${2:-}"

# The same Spanish copy (-AppleLanguages "(es)") pairs with different regions
# (-AppleLocale) to prove currency follows the region, not the language:
# es_MX → MXN, es_ES → EUR.
case "$locale_arg" in
  en|en-US|en_US)   languages="(en)";    apple_locale="en_US" ;;
  ptBR|pt-BR|pt_BR) languages="(pt-BR)"; apple_locale="pt_BR" ;;
  es|esMX|es-MX|es_MX) languages="(es)"; apple_locale="es_MX" ;;
  esES|es-ES|es_ES)    languages="(es)"; apple_locale="es_ES" ;;
  *) echo "Unknown locale '$locale_arg' (expected: en | ptBR | esMX | esES)" >&2; exit 1 ;;
esac

# Make sure the simulator is booted (no-op if it already is).
xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1 || xcrun simctl boot "$SIM" >/dev/null 2>&1 || true

if [ -n "$appearance" ]; then
  case "$appearance" in
    light|dark) xcrun simctl ui "$SIM" appearance "$appearance" >/dev/null ;;
    *) echo "Unknown appearance '$appearance' (expected: light | dark)" >&2; exit 1 ;;
  esac
fi

xcrun simctl terminate "$SIM" "$BUNDLE" >/dev/null 2>&1 || true
xcrun simctl launch "$SIM" "$BUNDLE" -AppleLanguages "$languages" -AppleLocale "$apple_locale" >/dev/null

echo "Launched $BUNDLE — locale=$apple_locale, appearance=${appearance:-unchanged}"
