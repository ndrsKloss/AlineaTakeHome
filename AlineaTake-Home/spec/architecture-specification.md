# Alinea — Architecture Specification

> **Purpose:** define how the Alinea app is structured — the layers, their responsibilities, navigation, dependency flow, and the project design system — as a standalone specification. This document defines *architecture*, not visual detail (see [`design-specification.md`](./design-specification.md)) or quality requirements (see [`non-functional-requirements.md`](./non-functional-requirements.md)); it references both where they constrain structure.
>
> **Scope reminder:** Alinea is a **single amount-entry screen** (numeric keypad + live amount, suggestion bubbles, a Review action, a back action). The architecture is deliberately **proportional** to that scope: it establishes clean, testable seams without introducing layers the current product does not need. Every guideline below states not only *what* to do but *when the abstraction is worth it*.
>
> **Path note:** the app source and this `spec/` directory live under `AlineaTake-Home/` in the repository. Paths in §2 are relative to the app source root.

---

## 1. Architecture Overview

Alinea uses **MVVM** with **coordinator-based navigation** on SwiftUI-native APIs, wired together at a single **composition root**, following **Dependency Inversion** and the **Single Responsibility Principle**.

The four roles and their one-directional dependencies:

```
        ┌─────────────┐   renders / sends intents   ┌──────────────┐
        │   SwiftUI    │ ─────────────────────────▶ │  ViewModel   │
        │    View      │ ◀───────────────────────── │ (@Observable)│
        └─────────────┘   observes presentation state└──────┬───────┘
              ▲                                              │ navigation intents
              │ built by                                     ▼
        ┌─────┴───────────────┐                       ┌──────────────┐
        │  Composition Root   │ ── injects ──────────▶│ Coordinator  │
        │ (root view factory) │                       │  (protocol)  │
        └─────────┬───────────┘                       └──────┬───────┘
                  │ owns                                      │ push/pop
                  ▼                                           ▼
            ┌───────────┐                              ┌────────────┐
            │ AppRouting │◀──────── implements ─────── │AppCoordinator│
            └───────────┘                              └────────────┘

  Leaf dependencies used by Views only: Design System components + Tokens.
```

Key properties:

- **Views are declarative and passive.** They render presentation state and forward user intents. They contain no business logic and no navigation logic.
- **View models own presentation state and logic.** They expose read state and intent methods; they never import SwiftUI view types or perform navigation directly.
- **Coordinators own navigation decisions.** Views and view models express *intent* ("the user tapped Review"); coordinators decide what that does.
- **Dependencies are supplied from the composition root** via constructor injection, so every type is testable in isolation.
- **Abstractions are introduced only where they buy testability or decoupling** (routing, coordination). Value types, tokens, and the single screen are used concretely.

Data flow is **unidirectional**: `user event → view calls VM intent → VM mutates state → SwiftUI re-renders`. Navigation intents leave the feature through the coordinator abstraction.

---

## 2. Project Folder Structure

Organized **by role within a feature**, plus shared foundation folders. Proposed layout (relative to the app source root `AlineaTake-Home/`):

```
AlineaTake-Home/
├── App/
│   ├── AlineaApp.swift              # @main App; renders the root view
│   └── RootView.swift               # composition root (factory + NavigationStack)
├── Navigation/
│   ├── AppRoute.swift               # Hashable enum of navigable destinations
│   ├── AppRouting.swift             # routing protocol (push/pop/popToRoot)
│   └── AppCoordinator.swift         # @Observable AppRouting impl over NavigationPath
├── Features/
│   └── AmountEntry/
│       ├── AmountEntryView.swift        # declarative view (+ private subviews)
│       ├── AmountEntryViewModel.swift   # @Observable presentation state/logic
│       ├── AmountEntryCoordinator.swift # AmountEntryCoordinating protocol + impl
│       └── Support/                     # feature-local helpers (e.g. AmountFormatter)
├── DesignSystem/
│   ├── Tokens/
│   │   ├── Spacing.swift             # spacing/layout tokens
│   │   ├── Radii.swift               # corner-radius tokens
│   │   ├── Colors.swift              # primitive + semantic color roles
│   │   └── Typography.swift          # scalable text styles + custom-font registration
│   ├── Components/
│   │   ├── AmountDisplay.swift
│   │   ├── KeypadKey.swift / Keypad.swift
│   │   ├── SuggestionChip.swift
│   │   ├── PrimaryGradientButton.swift
│   │   └── AutomatedBadge.swift
│   └── Catalog/
│       └── DesignSystemCatalogView.swift   # DEBUG-only preview gallery of components
├── Resources/
│   ├── Localizable.xcstrings         # en, pt-BR (mechanism = open, see §Alignment)
│   ├── Fonts/                        # bundled custom fonts (e.g. GT Flexa)
│   └── Assets.xcassets               # colors sets, icons, images
└── Preview Content/
    └── Mocks/                        # Mock coordinators/services for previews & tests
```

Rules:

- A feature folder contains **only that feature's** view, view model, coordinator, and feature-local support types.
- **Shared** navigation types, design system, and resources live in their own top-level folders and must not depend on any feature.
- Files are named for the single type they contain (§Naming).

---

## 3. Layer and Component Responsibilities

| Component | Owns | Must NOT |
|-----------|------|----------|
| **SwiftUI View** | Layout, rendering, gesture/tap wiring, forwarding intents to the view model, binding to VM state, applying design-system components/tokens. | Business rules, formatting logic, navigation, direct dependency construction, network/persistence. |
| **View Model** | Presentation state, derived/computed state, input handling, formatting, validation/enablement rules, calling coordinator intents. | Import SwiftUI view types, perform navigation itself, know about concrete infrastructure. |
| **Coordinator (feature)** | Translating feature intents (e.g. "show review", "go back") into routing calls; exposing intent-named methods. | Hold presentation state, render UI, contain business logic. |
| **Navigation Route** | Enumerating navigable destinations as `Hashable` values. | Carry view construction logic (that belongs to the composition root). |
| **App Router / AppCoordinator** | The navigation stack (`NavigationPath`) and `push/pop/popToRoot` primitives. | Know about specific features or their view models. |
| **Services** *(if introduced)* | A single external capability behind a protocol (e.g. haptics). | Own UI or presentation state. |
| **Repositories** *(not applicable now)* | Data access behind a protocol, if/when persistence or a backend is added. | — |
| **Composition Root** | Constructing and wiring coordinators → view models → views; owning the app coordinator; resolving routes to views. | Contain business/presentation logic. |
| **Design Tokens** | Named, reusable values (color roles, spacing, radii, text styles). | Encode component-specific layout. |
| **Reusable UI Components** | Self-contained, configurable visual building blocks consuming tokens. | Own feature state or navigation. |
| **Feature module** | A cohesive screen/flow (view + VM + coordinator + local support). | Depend on another feature's internals or on concrete infrastructure. |

---

## 4. MVVM Responsibilities

### 4.1 View
- A `struct: View` that receives its view model via `init` and stores it as `@State private var viewModel` (initialized with `State(initialValue:)`).
- Decomposed into small `private` subviews for readability; each subview receives only the data/bindings it needs.
- Reads state from the view model and calls **intent methods** on user actions (`viewModel.didTapKey(_:)`, `viewModel.didTapReview()`); uses `Binding`s the VM vends where two-way editing is needed.
- Applies design-system components and tokens; owns **no** literal colors, font sizes, or magic numbers that belong in tokens.

### 4.2 View Model
- An `@Observable final class`, injected with its coordinator (and any services) as **protocols**.
- Owns the amount-entry presentation state and logic, for example:
  - the entered amount value/state and its derived, **locale-formatted** display string (via a `Formatter`, not string concatenation — see `NFR-LOC-006/011`);
  - **suggestion-bubble visibility** (visible only when no amount is entered — design-spec §10.1);
  - **decimal-key enablement** state (the rule itself is an open product decision — design-spec §12 Q1, `NFR-LOC-011` — the VM exposes the enablement flag; it must not invent the rule);
  - caret and change-driven animation triggers as presentation state (design-spec §10.5/§10.8).
- Exposes **intent methods** for every user action and calls the coordinator for navigation intents.
- Contains no SwiftUI view types and constructs no dependencies itself.

### 4.3 View ⇄ ViewModel contract
- One view model instance per view, created by the composition root.
- The view never reaches around the view model to a coordinator, service, or route.

---

## 5. Navigation and Coordinator Responsibilities

Navigation is built on SwiftUI-native `NavigationStack` + `NavigationPath` and kept out of views.

### 5.1 Routing primitive
- **`AppRouting`** — a protocol exposing `push(_:)`, `pop()`, `popToRoot()`.
- **`AppCoordinator`** — an `@Observable final class` implementing `AppRouting`, owning a `NavigationPath`. It is the single source of truth for the navigation stack.

### 5.2 Routes
- **`AppRoute`** — a `Hashable` enum enumerating navigable destinations. It carries only identity/data, never view-building logic.
- For the current scope the reachable destinations are minimal (the Review and back actions are **tappable but perform no navigation yet** — design-spec §10). `AppRoute` MAY start empty or with a single placeholder case; it exists so adding a destination is a localized change.

### 5.3 Feature coordinators
- Each feature declares a coordinator **protocol** with **intent-named** methods, e.g. `AmountEntryCoordinating { func goBack(); func showReview() }`.
- The concrete `AmountEntryCoordinator` receives `AppRouting` by injection and maps intents to routing calls (`router.pop()`, `router.push(.review)`), or to a documented no-op while those flows are stubs.
- The view model depends on the **protocol**, so previews and tests inject a mock coordinator. Views never reference `AppRoute` or `AppRouting` directly.

---

## 6. Dependency Management and Dependency Inversion

- **Constructor injection** is the only DI mechanism. Every type receives its collaborators through `init`; nothing reaches for a global/singleton.
- **Depend on abstractions where it improves testability or separation** — specifically routing and coordination (and any future service/repository). The view model depends on `AmountEntryCoordinating`, not a concrete coordinator; the coordinator depends on `AppRouting`, not `AppCoordinator`.
- **Do not abstract for its own sake.** Value types (`Amount`, models), design tokens, formatters, and the single screen's view are used concretely. A protocol is justified only when there is a real second implementation (a mock for tests/previews counts) or a genuine seam to invert.
- **No DI container/framework.** The composition root (§7) is a plain factory — sufficient and clearer at this scale.
- **Feature code depends only on abstractions of infrastructure**, never on concrete infrastructure implementations, so a future backend/persistence/haptics implementation can be swapped without touching feature logic.

---

## 7. Composition Root

There is exactly **one** composition root: the root view (`RootView`), rendered by the `@main` `AlineaApp`.

Responsibilities:
- Own the `AppCoordinator` as `@State` and host the `NavigationStack(path:)`.
- Resolve routes to views via `.navigationDestination(for: AppRoute.self)`.
- Provide private **factory methods** (`makeAmountEntryView()`, …) that construct each feature's coordinator → view model → view and wire injected dependencies.

This is the only place that knows how to assemble concrete types. Adding a screen means adding a factory method and a `navigationDestination` case — nothing else changes. Example shape:

```swift
struct RootView: View {
    @State private var appCoordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            makeAmountEntryView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route { /* resolve future destinations */ }
                }
        }
    }

    private func makeAmountEntryView() -> some View {
        let coordinator = AmountEntryCoordinator(router: appCoordinator)
        let viewModel = AmountEntryViewModel(coordinator: coordinator)
        return AmountEntryView(viewModel: viewModel)
    }
}
```

---

## 8. Design System Structure

A small, **two-tier** design system under `DesignSystem/`, split into **Tokens** and **Components**, with a DEBUG-only **Catalog** view for visual verification.

- **Tokens** are the vocabulary: color roles, spacing, radii, and text styles. Components and views consume tokens; raw literals do not appear in feature code.
- **Components** are self-contained, configurable SwiftUI building blocks that consume tokens. Interactive styling is expressed as `ButtonStyle`s surfaced through view-extension modifiers; content elements are `View` structs with explicit inputs.
- **Catalog** (`DesignSystemCatalogView`, `#if DEBUG`) renders every component and state for quick visual/QA review and previews.

The design system is **reusable without being over-generalized**: components model the shapes the product actually uses (a keypad key, a suggestion chip, the gradient primary button) rather than an open-ended generic widget kit.

---

## 9. Design Tokens

Tokens realize the design-spec token candidates (design-spec §8) and satisfy the theming/accessibility NFRs. This section defines the **structure and rules**; concrete values come from the design spec and are not restated here.

### 9.1 Color — semantic, appearance-adaptive
- Two tiers: **primitives** (raw brand/neutral values) → **semantic roles** (e.g. `background`, `textPrimary`, `textPlaceholder`, `surfaceChip`, `brandGradientStart/End`, `onBrand`, `disabled*`). Feature code and components reference **semantic roles only**.
- Semantic roles **MUST resolve per appearance** (Light/Dark) — implemented as adaptive color assets or dynamic colors — to satisfy `NFR-THEME-003/004`. Because the Figma source is **Dark-only**, the **Light palette is an open decision** (`FAD-THEME-a`) that MUST NOT block establishing the role names now.
- No essential state is conveyed by color alone (`NFR-THEME-008`); components pair color with shape/opacity/label.

### 9.2 Spacing & radii
- Named spacing and corner-radius tokens (e.g. pill, control, surface radii) mirroring design-spec §5/§6. Layout uses these tokens rather than inline constants.

### 9.3 Typography — scalable + custom fonts
- Text styles are defined as reusable tokens applied via a single view modifier.
- Text styles **MUST participate in Dynamic Type**, and bundled **custom fonts (e.g. GT Flexa) MUST scale** with the user's text-size setting (`NFR-A11Y-001/002`). Fixed, non-scaling point sizes are non-compliant.
- The **large amount display** is a documented special case: it combines the design's content-driven shrink-to-fit (design-spec §10.7) with Dynamic Type; its scaling model is an open consideration (`FAD-A11Y-c`) and is treated distinctly from ordinary label styles.

---

## 10. Reusable SwiftUI Components

Derived from the repeated elements in design-spec §9. For each: what stays fixed vs. what is configurable. All consume tokens (§9) and hold no feature state or navigation.

| Component | Constant (from tokens/design) | Configurable inputs | Notes |
|-----------|-------------------------------|---------------------|-------|
| **AmountDisplay** | Display text style, centering, comma/locale grouping | text/value, `isPlaceholder`, `showCaret`, scale behavior | Placeholder vs. filled treatment; caret + change animation are inputs. |
| **Keypad / KeypadKey** | Grid geometry, digit text style, touch-target ≥ 44×44 (`NFR-A11Y-006`) | key label/icon, `isEnabled` (for the decimal key), `onPress` | Digit, decimal, and backspace variants; press feedback + haptics hook. |
| **SuggestionChip** | Pill shape/radius, chip surface role, chip text style | label, value, `onTap` | Rendered only when the amount is empty (visibility owned by the VM). |
| **PrimaryGradientButton** | Pill shape, gradient border/halo, label style, on-brand text role | label, `onTap`, gradient/animation config | The Review action; animated border is a component concern (design-spec §10.2). |
| **AutomatedBadge** | Gradient-bordered pill, condensed uppercase label style | label text | Prefer a live view over the flattened asset so it adapts to theme (`NFR-THEME-007`). |
| **BackControl** | Circular control, blurred backdrop, chevron | icon, `onTap` | Tappable; action routed via coordinator. |

Reuse is **design-supported** where design-spec §9 shows real repetition (keypad keys, chips); single-instance components (badge, primary button, back control) are componentized because they encapsulate non-trivial styling, not because reuse count demands it.

---

## 11. State and Data Flow

- **Single source of truth:** each screen's `@Observable` view model holds its presentation state; the view observes it.
- **Unidirectional cycle:** `user event → View calls a VM intent → VM mutates state (and/or computes derived state) → SwiftUI re-renders`. Two-way edits use `Binding`s vended by the view model.
- **Navigation is a side channel:** navigation intents flow `View → VM intent → Coordinator → AppRouting`, never mutating presentation state to represent navigation.
- **No shared mutable global state.** State lives in the owning view model; cross-feature data (none today) would pass through injected abstractions.
- **Formatting is derived, not stored redundantly:** the display string is computed from the entered value via a locale-aware formatter, keeping a single canonical amount value.

---

## 12. Protocol and Abstraction Guidelines

**Introduce a protocol when** there is a real seam to invert or a second implementation exists:
- routing (`AppRouting`) and feature coordination (`…Coordinating`) — enables mock injection for previews/tests and keeps views navigation-free;
- future services (e.g. haptics) and repositories — so feature code never depends on concrete infrastructure.

**Do NOT introduce a protocol for:**
- value types and domain models (`Amount`, models) — use them directly;
- design tokens and components — they are concrete building blocks;
- one-off helpers with a single implementation and no test seam;
- the single screen's view/view model themselves.

Rule of thumb: an abstraction must earn its place by improving **testability** or **decoupling from infrastructure**. If it does neither, prefer the concrete type.

---

## 13. Single Responsibility Guidelines

- **One type, one reason to change.** View = presentation; ViewModel = presentation state/logic; Coordinator = navigation; Component = one visual element; Token = one value vocabulary.
- **Decompose large views** into focused private subviews rather than one monolithic `body`.
- **Keep formatting, validation, and enablement logic in the view model** (or a small dedicated helper it owns), not in the view and not in the coordinator.
- **Coordinators stay thin** — intent-to-route mapping only.
- **Components stay focused** — a keypad key does not know about the amount value; the amount display does not know about the keypad.
- Prefer **small, composable types** over broad utilities that accumulate unrelated responsibilities.

---

## 15. Naming and File Organization Conventions

- **One primary type per file**, file named after the type (`AmountEntryViewModel.swift`).
- **Role suffixes:** `…View`, `…ViewModel`, `…Coordinator`; coordinator protocols use the `…Coordinating` suffix; routing protocol `AppRouting`, route enum `AppRoute`.
- **Design-system components** use a consistent, descriptive name (optionally a project prefix if adopted) and live in `DesignSystem/Components/`.
- **Tokens** use **semantic** names (roles/intent), never value-based names (`textPlaceholder`, not `whiteFaint`).
- **Feature-first folders**; shared foundations (`Navigation/`, `DesignSystem/`, `Resources/`) contain no feature dependencies.
- **Mocks** (mock coordinators/services) live under preview/test support, mirroring the protocol they implement.
- **Multi-line function signatures** (one parameter per line) for any function with more than one parameter.
- **All user-facing strings** come from localized resources — no hard-coded literals in views (`NFR-LOC-002`).

---

## Alignment with Existing Specifications & Open Decisions

This architecture is consistent with, and defers to, the other `spec/` documents:

- **Design specification** — component names and token intent here mirror design-spec §8–§9 (AmountDisplay, KeypadKey, SuggestionChip, gradient button, badge). Interaction ownership follows design-spec §10 (bubble visibility, animated border, caret, decimal enablement, amount scaling).
- **Non-functional requirements** — semantic, appearance-adaptive color tokens satisfy `NFR-THEME-003/004`; scalable typography with custom-font scaling satisfies `NFR-A11Y-001/002`; VM-owned locale-aware formatting and no-hardcoded-strings satisfy `NFR-LOC-002/006/011`; ≥44×44 touch targets on keypad keys satisfy `NFR-A11Y-006`.

**Open decisions (do not block establishing the structure):**
1. **Navigation depth** — the Review/back actions are currently no-ops (design-spec §10); the coordinator + `AppRoute` are included for testable separation and future flows. Confirm whether any real destination is in scope.
2. **Repository/data layer** — **not applicable now** (amount is local UI state). The `Repositories/` seam is described but intentionally omitted until persistence or a backend exists.
3. **Locale currency/decimal formatting** — owned by the view model/formatter; the exact currency policy and decimal-separator/keypad coupling remain open (`FAD-LOC-c/d`, design-spec §12 Q1).
4. **Custom-font registration mechanism** — approach to bundle and register scalable custom fonts is open (`FAD-A11Y-a`).
5. **Light Mode palette** — role names are defined now; concrete Light values are open (`FAD-THEME-a`), since the design source is Dark-only.
6. **Localization resource mechanism** — file format/organization is open (`FAD-LOC-a`); the architecture only requires that strings resolve from localized resources.

*This document defines architecture only; no production code is created or modified by it, and it does not alter the design or non-functional specifications.*
