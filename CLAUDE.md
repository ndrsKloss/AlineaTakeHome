# CLAUDE.md

Persistent instructions for every Claude Code session working on this project. Read this first.

## Project Overview

**AlineaTake-Home** is a SwiftUI iOS app implementing an **amount-entry screen** (numeric keypad + live amount display) from a Figma take-home design. The screen is **implemented** — keypad, live locale-formatted amount, quick-amount suggestion bubbles, an animated gradient Review button, haptics, a blinking caret, and the localization/theming/Dynamic Type NFRs. The design and requirements are captured in `spec/` and remain the source of truth (see the Specification-First Workflow below). See [`README.md`](README.md) for a feature/architecture overview.

- **Platform:** iOS (iPhone only, `TARGETED_DEVICE_FAMILY = 1`), portrait-only, SwiftUI, Swift 5.0.
- **Deployment target:** iOS 26.2. Bundle id: `shadow.inc.AlineaTake-Home`.
- **Entry point:** `AlineaTake-Home/AlineaTake_HomeApp.swift` → `RootView` (`App/RootView.swift`, the composition root hosting the `NavigationStack` and building the amount-entry feature). There is no `ContentView` placeholder.
- **Architecture:** MVVM + coordinator navigation, constructor injection, a two-tier design system (semantic tokens → components). Full detail in `spec/architecture-specification.md`.

## Repository Structure

```
AlineaTake-Home/                     # repo root (git)
├── CLAUDE.md                        # this file
├── README.md                        # feature/architecture overview
├── test-locale.sh                   # locale + appearance sim launcher
├── AlineaTake-Home.xcodeproj/       # Xcode project
├── AlineaTake-HomeTests/            # Swift Testing target (entry model, formatter, VM)
└── AlineaTake-Home/                 # app source group
    ├── AlineaTake_HomeApp.swift     # @main App
    ├── App/RootView.swift           # composition root (factory + NavigationStack)
    ├── Navigation/                  # AppRoute · AppRouting · AppCoordinator
    ├── Features/AmountEntry/        # View · ViewModel · Coordinator · AmountEntry · AmountFormatter
    ├── DesignSystem/                # Tokens/ · Components/ (Alinea…) · Catalog/ (DEBUG)
    ├── Services/                    # HapticFeedback
    ├── Mocks/                       # mock coordinator + haptics (previews/tests)
    ├── Resources/Fonts/             # GT Flexa, Instrument Sans SemiCondensed (custom fonts)
    ├── Localizable.xcstrings        # String Catalog (base en + pt-BR + es)
    ├── Assets.xcassets/             # asset catalog (colors, icons, images)
    └── spec/                        # ⭐ specifications — source of truth
        ├── design-specification.md          # visual/layout/interaction spec from Figma
        ├── non-functional-requirements.md   # localization, theming, Dynamic Type NFRs
        └── architecture-specification.md    # MVVM + coordinator, DI, design-system structure
```

> **Note on the `spec/` path:** the specification directory referenced throughout this document lives at **`AlineaTake-Home/spec/`** (inside the source group), not at the repo root. Every rule below that says "the `spec/` directory" means that path.

## Build & Run

- Open `AlineaTake-Home.xcodeproj` in Xcode, or from the CLI:
  ```
  xcodebuild -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
    -destination 'generic/platform=iOS Simulator' build
  ```
- Tests live in the **`AlineaTake-HomeTests`** target (Swift Testing — `@Test`/`#expect`). Run them with:
  ```
  xcodebuild test -project AlineaTake-Home.xcodeproj -scheme AlineaTake-Home \
    -destination "id=<simulator-udid>"
  ```
- There is no dependency manager configured; there are no third-party dependencies.

## Testing Localization in the Simulator

The app localizes copy into **American English (`en-US`, base)**, **Brazilian Portuguese (`pt-BR`)**, and **Spanish (`es`)** via `Localizable.xcstrings`, with locale-aware number/currency formatting.
To switch locale quickly while testing:

**Per-launch override (fastest — no global settings change).** Pass launch arguments
to override just this app's locale. `-AppleLanguages` drives translated copy;
`-AppleLocale` drives number/currency formatting — set **both**:

```bash
SIM=<simulator-udid>          # e.g. iPhone 17 Pro: 568E4EAE-6327-40B3-95DD-344F0260A588
BUNDLE=shadow.inc.AlineaTake-Home

xcrun simctl terminate $SIM $BUNDLE 2>/dev/null   # if already running

# Brazilian Portuguese
xcrun simctl launch $SIM $BUNDLE -AppleLanguages "(pt-BR)" -AppleLocale pt_BR

# American English
xcrun simctl launch $SIM $BUNDLE -AppleLanguages "(en)" -AppleLocale en_US

# Toggle appearance for the light/dark validation matrix
xcrun simctl ui $SIM appearance dark   # or: light
```

Note the argument shapes: `-AppleLanguages` takes a parenthesized list `"(pt-BR)"`;
`-AppleLocale` uses an underscore (`pt_BR`, `en_US`).

**Xcode scheme (best for tapping through the UI).** Product → Scheme → Edit Scheme →
**Run → Options → App Language / App Region**, set Language = *Portuguese (Brazil)* and
Region = *Brazil*, then Run. Persists across runs until changed back.

**Helper script:** `./test-locale.sh` (repo root) wraps the launch args:

```bash
./test-locale.sh ptBR dark     # pt-BR, dark appearance
./test-locale.sh en light      # en-US, light appearance
./test-locale.sh ptBR          # pt-BR, leave appearance unchanged
```

It defaults `SIM` to `"iPhone 17 Pro"` and `BUNDLE` to `shadow.inc.AlineaTake-Home`;
override either via env var (e.g. `SIM=<udid> ./test-locale.sh ptBR dark`).

**Note:** copy and formatting are independent axes. `-AppleLanguages` selects the
translated copy (from `Localizable.xcstrings`); `-AppleLocale` drives number/currency
formatting (`R$ 1.234,56`). Set **both** to validate a locale end-to-end — a language
with no translation entry falls back to English copy while still formatting per `-AppleLocale`.

---

# Project Instructions

## Specification-First Workflow

Before planning, creating, modifying, refactoring, or deleting any production code, you MUST inspect the contents of the `spec/` directory.

Treat the documents in `spec/` as the primary source of truth for:

* visual design;
* layout and interaction requirements;
* functional requirements;
* non-functional requirements;
* accessibility expectations;
* localization behavior;
* theme support;
* implementation constraints already agreed upon;
* open questions and unresolved decisions.

Do not begin implementation based only on the current user prompt when relevant specifications already exist.

## Required Pre-Change Process

Before making any code changes, you MUST:

1. List the files available in `spec/`.
2. Read every specification relevant to the requested task.
3. Identify the requirements and constraints affected by the proposed change.
4. Check for contradictions, ambiguities, or unresolved decisions.
5. Summarize the relevant requirements in your working plan before editing code.

For broad architectural work, foundational components, or cross-cutting changes, read the entire `spec/` directory rather than only one document.

## Source-of-Truth Priority

When instructions conflict, use the following priority order:

1. The user's latest explicit instruction.
2. Approved decisions documented in `spec/`.
3. Existing project architecture and conventions.
4. Reasonable implementation assumptions.

If the latest user instruction appears to conflict with an existing specification, explicitly identify the conflict before implementing the change. Do not silently override the specification.

## No Silent Assumptions

Do not invent missing product behavior, visual details, business rules, or architecture constraints.

When information is missing:

* record the assumption explicitly;
* keep the decision reversible where possible;
* distinguish temporary implementation assumptions from approved requirements;
* avoid modifying specification files unless the user explicitly requests it.

## Specification Preservation

Do not modify files inside `spec/` as a side effect of an implementation task.

Only create, edit, rename, or delete specification files when the user explicitly asks for a specification change.

If implementation reveals that a specification is incomplete or inconsistent, report the issue rather than silently rewriting the document.

## Validation

Before considering a task complete, verify the implementation against the relevant specification documents.

The final task summary must include:

* which specification files were consulted;
* which requirements were implemented;
* any deviations from the specifications;
* assumptions made;
* unresolved issues;
* validation or tests performed.

## Project-Wide Quality Requirements

Unless a specification explicitly states otherwise, all implementation work must preserve:

* English and Brazilian Portuguese localization support;
* Light Mode and Dark Mode compatibility;
* Dynamic Type support;
* accessibility;
* visual fidelity to the approved Figma specification;
* maintainable and testable code.
