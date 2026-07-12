# Alinea — Amount Entry

Built spec-first — the design, non-functional requirements, and architecture are
captured under [`AlineaTake-Home/spec/`](AlineaTake-Home/spec/) and treated as the
source of truth (see [`CLAUDE.md`](CLAUDE.md)).

| Platform | Min iOS | Language | UI | Dependencies |
|----------|---------|----------|----|--------------|
| iPhone + iPad (universal) | 26.2 | Swift 5 | SwiftUI | None |

---

## Figma requirements — how each is met

The Figma comments are the product spec ([design-spec §10](AlineaTake-Home/spec/design-specification.md)).
All eight are implemented:

| # | Requirement | Where it lives |
|---|-------------|----------------|
| 1 | **Suggestion bubbles only when nothing is entered** | `AmountEntryViewModel.isAmountPlaceholder` gates the action band; bubbles ⇄ Review are two branches of one transition in `AmountEntryView`. |
| 2 | **Border gradient animates** | `AlineaSpecialButton` — a magenta→purple gradient border/halo that animates continuously. |
| 3 | **Animated bubbles → button transition** | `AmountEntryView.bandTransition` — an asymmetric fade that chains out-then-in (old band fades out, new band fades in). |
| 4 | **Keypad haptics** | Every intent (`didTapDigit/Decimal/Delete`) fires `HapticFeedback.keyPressed()`; injected behind a protocol (`SystemHapticFeedback`), so it's testable/swappable. A disabled decimal key can't fire (its `Button` is `.disabled`). |
| 5 | **Blinking caret, always at the end** | `AlineaAmountDisplay` renders a self-blinking bar — centered between symbol and `0` when empty (`$|0`), trailing the value once typed. |
| 6 | **Decimal key disabled when inappropriate** | `AmountEntryViewModel.isDecimalEnabled` = no separator entered yet. The keypad glyph is locale-coupled (`.` en / `,` pt-BR, `NFR-LOC-011`). |
| 7 | **Amount shrinks to fit** | `AlineaAmountDisplay` uses `lineLimit(1)` + `minimumScaleFactor`; the entry model also caps integer length (12) to guard overflow. |
| 8 | **Animation on digit edits** | Value edits blur-crossfade (old value blurs+fades out, new blurs in) via a string-keyed transition; the clearing delete snaps to the placeholder instead of fading. Gated on Reduce Motion. |

---

## Non-functional requirements

All three NFR areas are implemented ([non-functional-requirements](AlineaTake-Home/spec/non-functional-requirements.md)):

- **Localization** — English (base), Brazilian Portuguese, and Spanish via a
  String Catalog; **locale-aware** currency/number formatting (`$1,234.56` /
  `R$ 1.234,56`). No hard-coded user-facing strings.
- **Light + Dark Mode** — semantic, appearance-adaptive color roles
  (`SemanticColors`); Dark is the Figma design verbatim, Light is a derived,
  WCAG-AA re-theme.
- **Dynamic Type** — text scales with the system setting, including the bundled
  **custom fonts**; the amount display reconciles content-driven shrink-to-fit
  with Dynamic Type.

---

## Build & run

Open `AlineaTake-Home.xcodeproj` in Xcode and run, or from the CLI:

```bash
xcodebuild -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
  -destination 'generic/platform=iOS Simulator' build
```

### Tests

Swift Testing (`@Test` / `#expect`) in the `AlineaTake-HomeTests` target — 32
tests across the entry model, formatter, and view model:

```bash
xcodebuild test -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
  -destination "id=<simulator-udid>"
```

### Testing locale & appearance

Use the helper to relaunch under a locale/appearance without changing global
settings (defaults to the iPhone 17 Pro simulator):

```bash
./test-locale.sh ptBR dark     # pt-BR, dark
./test-locale.sh en light      # en-US, light
```
