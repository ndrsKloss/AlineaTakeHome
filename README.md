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

- **Localization & internationalization (l10n / i18n)** — English (base),
  Brazilian Portuguese, and Spanish via a String Catalog; **locale-aware**
  currency/number formatting (`$10,000.50` / `R$ 10.000,50` / `10.000,50 €`).
  Currency is region-derived, so Spanish resolves to **EUR** in Spain and
  **MXN** in Mexico. No hard-coded user-facing strings.
- **Light + Dark Mode** — semantic, appearance-adaptive color roles
  (`SemanticColors`); Dark is the Figma design verbatim, Light is a derived,
  WCAG-AA re-theme.
- **Dynamic Type** — text scales with the system setting, including the bundled
  **custom fonts**; the amount display reconciles content-driven shrink-to-fit
  with Dynamic Type.
- **Fonts & assets** — the design's custom fonts (**GT Flexa Condensed Medium**
  and **Instrument Sans SemiCondensed Medium**) are bundled and registered at
  launch via Core Text (`AlineaFonts`), then applied through the typography
  tokens. All image assets are exported from the Figma file (`ic_chevron`,
  `ic_delete_numpad`, `img_badge_border`). The `ic_chevron` and `ic_delete_numpad`
  glyphs are template-rendered and tint per appearance; `img_badge_border` is a
  holographic-foil texture rendered verbatim and is intentionally
  appearance-independent (brand identity).

### Designing for a Broader Investor Base

Because Alinea is an investment platform, accessibility (a11y) is not only a technical quality attribute—it is also a product and business consideration.

People with visual or hearing impairments also invest, manage their finances, and make financial decisions. Excluding these users means unnecessarily limiting the platform’s potential audience. For that reason, I went beyond the core visual implementation and treated accessibility, localization, and adaptive typography as foundational requirements rather than optional enhancements.

The implementation includes support for:

* Dynamic Type
* VoiceOver
* Semantic accessibility labels and traits
* Localization for Brazilian Portuguese, American English and Spanish
* Locale-aware monetary formatting
* Light and dark appearance support

The current layout supports Dynamic Type up to the largest accessibility size that can be accommodated without compromising the screen’s hierarchy, usability, or interaction model. Supporting more extreme text sizes would likely require a dedicated accessibility layout rather than simply scaling the existing design—for example, restructuring horizontal components, changing control proportions, or introducing alternative presentation patterns.

---

## Design system & catalog

The Figma design is translated into a small, two-tier design system under
`DesignSystem/` rather than one-off view code:

- **Tokens** — the design's vocabulary is captured as named tokens
  (`ColorPalette`/`SemanticColors`, `Spacing`, `Radius`, `Typography`). Feature
  code and components reference semantic roles, never raw literals, so a single
  change re-themes the app and every value stays traceable back to the design.
- **Components** — each repeated Figma element is its own reusable, token-driven
  SwiftUI component (`AlineaAmountDisplay`, `AlineaKeyboard`, `AlineaChip`,
  `AlineaSpecialButton`, `AlineaAppBar`, `AlineaAutomatedBadge`, `AlineaNumber`).
- **Catalog** — a DEBUG-only `DesignSystemCatalogView` renders every component and
  token (colors, typography, spacing, radii) in isolation, mirroring the Figma
  design so the pieces can be reviewed and QA'd outside the screen itself.

**A note on Figma values:** several spacings and sizes in the Figma file are
non-integer (e.g. keypad glyphs at `36.647`, a `29.869` pill radius, sub-pixel
offsets). Rather than hard-code every fractional value, we reconciled them to
clean, consistent token values that best represent the intended design while
keeping the layout coherent across device sizes, Dynamic Type, and both
appearances. The result stays faithful to the design without inheriting
measurement artifacts from the source file.

**A note on visual effects:** a few decorative effects — notably the Review
button's gradient halo and the top glow behind the amount — were tuned to be
slightly more prominent than the Figma source. This is a deliberate choice to
make the animated/glow work clearly evident to the team evaluating the
submission, not an accidental deviation from the design.

### A note on code comments

The source is intentionally heavily commented — most types and non-obvious
decisions carry inline rationale (often referencing the exact spec requirement,
e.g. `NFR-LOC-011` or `design-spec §10.7`). This verbosity is deliberate: it
gives AI coding agents the context they need to navigate the codebase and make
correct, spec-aligned changes, keeping the design intent traceable directly from
the code rather than only from the specs.

---

## Build & run

Open `AlineaTake-Home.xcodeproj` in Xcode and run, or from the CLI:

```bash
xcodebuild -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
  -destination 'generic/platform=iOS Simulator' build
```

### Tests

Swift Testing (`@Test` / `#expect`) in the `AlineaTake-HomeTests` target — 58
tests across the entry model, formatter, and view model, plus the cross-cutting
NFRs: accessibility (spoken VoiceOver values + per-language localized labels),
semantic colors resolving per light/dark appearance, the scalable keypad
typography (Dynamic Type), and view-model locale wiring across en / pt-BR / es:

```bash
xcodebuild test -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
  -destination "id=<simulator-udid>"
```

A separate `AlineaTake-HomeUITests` XCUITest target drives the **real
accessibility tree** and runs Apple's automated accessibility audit:

- `VoiceOverLocalizationUITests` — asserts the localized VoiceOver labels in each
  language (en / pt-BR / es).
- `AppearanceAndDynamicTypeUITests` — relaunches the screen across every
  combination of language × appearance (light / dark) × text size
  (default / accessibility) and verifies it stays labeled, hit-testable, and
  audit-clean.
- `AmountEntryInteractionUITests` — drives the keypad end-to-end (typing digits,
  delete, decimal entry + disable rule, chip selection) and asserts the amount
  and the empty⇄filled state respond.

Run the UI tests with the helper (defaults to the interaction tests; pass a
class, `Class/method`, or `all`):

```bash
./run-uitests.sh                              # AmountEntryInteractionUITests
./run-uitests.sh VoiceOverLocalizationUITests
./run-uitests.sh all                          # the whole UI-test target
```

### Testing locale & appearance

Use the helper to relaunch under a locale/appearance without changing global
settings (defaults to the iPhone 17 Pro simulator):

```bash
./test-locale.sh ptBR dark     # pt-BR, dark
./test-locale.sh en light      # en-US, light
```
