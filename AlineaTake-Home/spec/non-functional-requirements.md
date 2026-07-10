# Alinea — Non-Functional Requirements

> **Purpose:** define *what* the application must support for localization, theming, and text scaling, and *how compliance is evaluated* — **before** any architecture or implementation decisions are made.
> This document deliberately does **not** choose APIs, dependencies, frameworks, file formats, or code patterns. Those are recorded as **Future Architecture Decisions (FAD)** to be resolved separately.
>
> **Companion document:** [`design-specification.md`](./design-specification.md). Where an NFR here **extends or modifies** behavior implied by the Figma file, the extension is called out explicitly (see the "Relationship to the design specification" note in each area and the ⚠️ markers).
>
> **Normative language:** **MUST** = mandatory · **SHOULD** = strongly recommended · **MAY** = optional. Requirement IDs are stable references (`NFR-<AREA>-NNN`).
>
> **Scope guard:** this document covers three areas only — Localization/i18n, Light/Dark Mode, and Dynamic Type. Other non-functional concerns (performance, security, offline, analytics, etc.) are out of scope for now.

---

## 1. Localization and Internationalization (`NFR-LOC`)

### 1.1 Objective
The application MUST present all user-facing content in the user's preferred language, initially **English (en)** and **Brazilian Portuguese (pt-BR)**, with locale-correct formatting of numbers and currency, without regressing the layout or meaning of the Figma design.

### 1.2 Scope
- **In scope:** all visible UI strings, accessibility text (labels, hints, values), number/currency/decimal formatting, text-expansion tolerance, language selection and fallback.
- **Out of scope (for now):** the localization API, file format, code-generation strategy, resource organization, translation tooling, and pluralization engine — all **FAD** (§1.8).
- **Initial locales:** `en`, `pt-BR`. Additional locales MAY be added later; the design MUST NOT preclude them.

### 1.3 User-visible behavior
- The app **MUST** display all copy (e.g., `AUTOMATED` badge text, `Review` button label, any future error/helper text) in the active language.
- The displayed language **SHOULD** follow the device's **preferred language** ordering; when the top preferred language is unsupported, the app **MUST** fall back per §1.4.
- Numbers, currency, and decimal separators **MUST** render using locale-aware formatting (§1.6).

### 1.4 Requirements

| ID | Level | Requirement |
|----|-------|-------------|
| `NFR-LOC-001` | MUST | The app MUST support **English** and **Brazilian Portuguese** as first-class locales. |
| `NFR-LOC-002` | MUST | User-facing strings **MUST NOT** be hard-coded in SwiftUI views; every visible string MUST come from a localizable resource resolved at runtime. |
| `NFR-LOC-003` | SHOULD | The active language **SHOULD** follow the device's preferred-language settings (system order), not an in-app hard-coded default. |
| `NFR-LOC-004` | MUST | The app **MUST** define a sensible **fallback language** used when no preferred language is supported. Fallback = **English (en)** unless changed by a future decision. |
| `NFR-LOC-005` | MUST | Layouts **MUST** tolerate text expansion/contraction between en and pt-BR without clipping, truncation of essential meaning, or overlap. (pt-BR strings are frequently longer — plan for ~+30–40% width.) |
| `NFR-LOC-006` | MUST | Numbers, currency values, and decimal separators **MUST** use locale-aware formatting where applicable (§1.6). |
| `NFR-LOC-007` | MUST | Localized strings **MUST** preserve intended meaning and **MUST NOT** rely on string concatenation that can break grammar, word order, or gender/number agreement in another language. Interpolated values MUST use ordered/named placeholders. |
| `NFR-LOC-008` | MUST | Pluralized or count-dependent copy (if introduced) **MUST** use a plural-aware mechanism, not manual `if count == 1` branching. |
| `NFR-LOC-009` | MUST | Accessibility labels, hints, and values **MUST** be localized to the same standard as visible text (§3 cross-cuts VoiceOver). |
| `NFR-LOC-010` | SHOULD | The app **SHOULD** be prepared for right-to-left (RTL) layout mirroring in future locales; the initial two locales are LTR, so RTL is **not** a launch requirement but MUST NOT be actively broken by hard-coded left/right assumptions. |

### 1.5 Engineering constraints
- No literal user-facing strings in view bodies (`NFR-LOC-002`) — enforced by review/lint (mechanism = FAD).
- Value interpolation uses positional/named tokens, never `"\(a)" + "\(b)"` sentence assembly (`NFR-LOC-007`).
- Formatting derives from the **current locale**, not the current language alone (locale can differ from UI language).

### 1.6 Number, currency, and decimal formatting ⚠️
The Figma design hard-shows an amount as `$2,000` — a **USD** symbol with an **en-US** grouping separator (`,`) and a keypad **decimal key `.`**. Under locale-aware formatting these become variable:

| Concern | en-US (as in Figma) | pt-BR | Requirement |
|---------|--------------------|-------|-------------|
| Grouping separator | `,` (`2,000`) | `.` (`2.000`) | `NFR-LOC-006` — grouping MUST follow locale for **display**. |
| Decimal separator | `.` | `,` | ⚠️ Open — the keypad's decimal key is labeled `.` in Figma; see `NFR-LOC-011`. |
| Currency symbol/position | `$` prefix | `R$ ` prefix (with space) | ⚠️ Open — is the currency fixed (USD) or locale-driven? See `NFR-LOC-012`. |

| ID | Level | Requirement |
|----|-------|-------------|
| `NFR-LOC-011` | MUST | The **displayed** amount MUST use locale-correct grouping/decimal separators. The **decimal key glyph and the separator the user types** MUST be consistent with the active locale (`.` in en, `,` in pt-BR) — the implementation MUST NOT show a `.` key while formatting with a `,` decimal, or vice versa. *(Extends the design spec, which shows only `.`.)* |
| `NFR-LOC-012` | MUST | The currency treatment (symbol, symbol position, and whether the currency is fixed vs. locale-derived) MUST be defined before implementation. Until resolved, treat the `$`/USD in Figma as a **placeholder**, not a confirmed product decision (see §1.8, and design-spec §12 Q1/Q2). |

### 1.7 Acceptance criteria
- With device language = English: all copy in English; `2,000` grouped with `,`; fallback not triggered.
- With device language = Português (Brasil): all copy in pt-BR; grouping `2.000`; decimal/keypad consistent with pt-BR (`NFR-LOC-011`).
- With device language = an unsupported language (e.g., French): app renders in the fallback language (`NFR-LOC-004`), not a mix.
- No visible string appears untranslated (no raw keys, no English leaking into pt-BR).
- No layout in either language clips or overlaps essential content at default text size (`NFR-LOC-005`).
- VoiceOver reads localized labels/values in the active language (`NFR-LOC-009`).

### 1.8 Testing and validation considerations
- Run the app under each supported locale (and at least one **pseudo-locale**/long-string or unsupported locale) to exercise expansion and fallback.
- Visual review of the amount display, chips, badge, and button in both languages.
- Snapshot/UI comparison across `en` and `pt-BR` for the amount-entry screen.
- Audit views for hard-coded strings (`NFR-LOC-002`) and for concatenation (`NFR-LOC-007`).
- VoiceOver pass in both languages.

### 1.9 Unresolved decisions / assumptions (Future Architecture Decisions)
- **FAD-LOC-a:** localization API, resource file format, key naming, and organization.
- **FAD-LOC-b:** code-generation vs. runtime string lookup; pluralization mechanism.
- **FAD-LOC-c:** currency policy — fixed USD vs. locale currency; symbol position; number of decimal places (design-spec §12 Q1). ⚠️
- **FAD-LOC-d:** decimal-separator/keypad coupling to locale (`NFR-LOC-011`). ⚠️
- **Assumption:** the two launch locales are `en` and `pt-BR`, both LTR; RTL deferred.

**Relationship to the design specification:** the Figma file is authored in **en-US only** (`$`, `,`, `.`). Requirements `NFR-LOC-006/011/012` **extend** it to locale-aware behavior; any change to currency symbol or separators is an intentional extension, not a contradiction of the design.

---

## 2. Light Mode and Dark Mode (`NFR-THEME`)

### 2.1 Objective
The application MUST render correctly and legibly in both **Light Mode** and **Dark Mode**, preserving the visual hierarchy and emphasis established by the Figma design, following the system appearance by default.

### 2.2 Scope
- **In scope:** semantic color definition; legibility of text, backgrounds, borders, gradients, shadows, icons, and all interaction/selected/disabled states in both appearances; asset adaptation; non-color-dependent information.
- **Out of scope (for now):** the concrete color-token catalog, theme architecture, and asset pipeline — all **FAD** (§2.8).

### 2.3 Relationship to the design specification ⚠️ (important)
**The Figma design provides a single, Dark appearance only** (background `#18161F`, white foreground, brand-gradient accents — see design-spec §5/§8). There is **no Light Mode design in Figma.** Therefore:
- Dark Mode is **design-confirmed**; Light Mode is a **documented extension** whose palette has been **derived and ratified** (`FAD-THEME-a`, see §2.10).
- Light Mode MUST preserve the *same visual hierarchy, emphasis, and semantic intent* as the Dark design — it is a re-theming, not a redesign.

### 2.4 User-visible behavior
- The interface **MUST** follow the **system appearance** by default and update live when the user switches Light/Dark.
- In both appearances, all content and controls **MUST** remain legible and retain their intended emphasis (e.g., the primary `Review` action stays visually dominant; the `AUTOMATED` badge stays a secondary accent; the faint `$0` placeholder stays clearly de-emphasized relative to an entered amount).

### 2.5 Requirements

| ID | Level | Requirement |
|----|-------|-------------|
| `NFR-THEME-001` | MUST | The app **MUST** support both Light Mode and Dark Mode. |
| `NFR-THEME-002` | SHOULD | The app **SHOULD** follow the **system appearance** by default (no forced single theme) and respond to live appearance changes. |
| `NFR-THEME-003` | MUST | Colors **MUST** be described **semantically** (role-based, e.g. *background / primary-text / brand-accent / on-brand / surface-elevated / disabled*) rather than only by raw hex values, so each role can resolve per appearance. |
| `NFR-THEME-004` | MUST | Text, backgrounds, borders, gradients, shadows, icons, **selected**, **disabled**, and **interactive/pressed** states **MUST** remain legible and visually distinct in **both** appearances. |
| `NFR-THEME-005` | MUST | The **visual hierarchy and emphasis** from the Figma design **MUST** be preserved in both themes (primary vs. secondary vs. de-emphasized elements keep their relative weight). |
| `NFR-THEME-006` | MUST | Contrast **MUST** be sufficient for relevant content and controls in both appearances. Target: **WCAG 2.1 AA** — ≥ 4.5:1 for normal text, ≥ 3:1 for large text (≥ ~24 px) and essential UI/graphical elements. Large decorative/brand glows are exempt where they carry no essential information. |
| `NFR-THEME-007` | MUST | Assets that do not adapt automatically (e.g., the flattened `AUTOMATED` badge PNG, backspace/chevron glyphs, the Review glow composite — design-spec §7) **MUST** define appropriate Light and Dark behavior (adaptive asset, tint, or a rebuilt live view). |
| `NFR-THEME-008` | MUST | **No essential information may depend on color alone.** State (selected, disabled, error, active) MUST also be conveyed by shape, text, icon, opacity, or position. |
| `NFR-THEME-009` | SHOULD | Gradients, glows, and shadows (Review halo, top glow ellipse, pill bloom) **SHOULD** be re-tuned per appearance so they read as intended (a glow tuned for a dark background can wash out on a light one). |
| `NFR-THEME-010` | MAY | The app **MAY** offer an in-app appearance override (Light/Dark/System) in the future; not required for launch. |

### 2.6 Engineering constraints
- Every color used in a view resolves through a **semantic role**, not a literal (`NFR-THEME-003`). The role→value mapping per appearance is a FAD.
- Adaptive assets or per-appearance variants must exist for any non-vector, non-tintable asset (`NFR-THEME-007`).
- State indication must be multi-channel (`NFR-THEME-008`).

### 2.7 Acceptance criteria
- Toggling system appearance updates the entire screen with no unreadable text, invisible borders, or lost controls in either mode.
- Primary `Review` action remains the most prominent control in both modes; `$0` placeholder remains clearly fainter than an entered amount in both modes.
- Measured contrast meets `NFR-THEME-006` for all text and essential controls in both modes.
- Every stateful element (disabled decimal key, selected/pressed chip, pressed button) is distinguishable **without** relying on hue alone.
- No asset appears as a dark-on-dark or light-on-light "ghost" in the opposite appearance.

### 2.8 Testing and validation considerations
- Run the screen in Light and Dark (and switch live) on device/simulator.
- Contrast measurement on text and controls in both modes.
- Grayscale/"remove color" pass to verify `NFR-THEME-008` (information survives without color).
- Visual QA of gradients/glows/shadows in both modes (`NFR-THEME-009`).
- Verify each §7 asset in both appearances.

### 2.9 Unresolved decisions / assumptions (FAD)
- **FAD-THEME-a:** ✅ **RESOLVED (2026-07-10)** — the Light Mode palette has been derived and ratified; see §2.10.
- **FAD-THEME-b:** the semantic color-token catalog and theme architecture. *(Partially realized: roles live in `DesignSystem/Tokens/SemanticColors.swift`; full catalog/architecture still open.)*
- **FAD-THEME-c:** asset strategy for non-adaptive assets (rebuild live vs. per-appearance exports). *(Current glyphs — `ic_chevron`, `ic_delete_numpad` — use **template rendering + semantic tint**; badge/glow assets still open.)*
- **FAD-THEME-d:** how brand gradients/glows are expressed per appearance.
- **Assumption:** Dark Mode == the current Figma design verbatim; Light Mode is a faithful re-theme preserving hierarchy.

### 2.10 Resolved: Light Mode palette (`FAD-THEME-a`) ✅

Ratified **2026-07-10**. Dark values are the Figma design verbatim; Light values are **derived** (no Figma reference) as a faithful re-theme preserving hierarchy, emphasis, and semantic intent (`NFR-THEME-005`) at WCAG AA contrast (`NFR-THEME-006`). Implemented as adaptive `Color(light:dark:)` roles in `DesignSystem/Tokens/SemanticColors.swift` (Light background primitive `cloud` `#F4F3F8` in `ColorPalette.swift`).

| Semantic role | Dark (Figma) | Light (derived) | Rationale / assumption |
|---|---|---|---|
| `background-primary` | `#18161F` | `#F4F3F8` | soft cool off-white mirroring the dark bg's purple undertone |
| `text-primary` | `#FFFFFF` | `#18161F` | near-black on light (~15:1 contrast) |
| `text-placeholder` | white @4% | `#18161F` @20% | faint `$0` ghost, de-emphasized; light needs >4% to read as a comparably faint ghost |
| `surface-chip` | `#23212C` @75% | `#18161F` @8% | subtle elevated grey pill; dark label stays legible |
| `brand-gradient-start` | `#B24DCC` | `#B24DCC` (same) | brand identity is appearance-independent; reads on both backgrounds |
| `brand-gradient-end` | `#8955F9` | `#8955F9` (same) | same |
| `on-brand` | `#22212D` | `#FFFFFF` | label on the primary button; white on the inverted (dark) light-mode pill |
| `primary-button-surface` | `#FFFFFF` | `#18161F` | Review pill **inverts to dark** on a light bg to stay dominant (`NFR-THEME-005`); not yet used in UI — revisit when the Review button is built |

**Assumptions carried:** brand gradients are kept identical across appearances (`NFR-THEME-009` re-tuning remains SHOULD; large glows are contrast-exempt); disabled/error roles remain undefined (design-spec §12); the `primary-button-surface` / `on-brand` Light treatment is forward-looking and to be re-validated when the Review button is implemented.

---

## 3. Dynamic Type and System Font Scaling (`NFR-A11Y`)

### 3.1 Objective
The application MUST respond to the user's system text-size preferences (Dynamic Type), keeping core content and controls readable, reachable, and usable across supported text sizes, including accessibility sizes.

### 3.2 Scope
- **In scope:** scaling of all user-facing text (including custom fonts), adaptive layout when larger text no longer fits, touch-target preservation, and controlled truncation/min-scale behavior.
- **Out of scope (for now):** whether to use semantic text styles, `@ScaledMetric`, `UIFontMetrics`, specific breakpoints, or accessibility-specific alternate layouts — all **FAD** (§3.9).

### 3.3 User-visible behavior
- Text **MUST** grow and shrink with the system text-size setting.
- Content and controls **MUST** remain usable at larger sizes — no essential text clipped, overlapped, or pushed off-screen; controls stay tappable.

### 3.4 Requirements

| ID | Level | Requirement |
|----|-------|-------------|
| `NFR-A11Y-001` | MUST | User-facing text **MUST** scale appropriately with **Dynamic Type**. |
| `NFR-A11Y-002` | MUST | Custom fonts (**GT Flexa**, **Instrument Sans SemiCondensed** — design-spec §4) **MUST** participate in system scaling. Fixed point sizes that ignore Dynamic Type are non-compliant. |
| `NFR-A11Y-003` | MUST | Core content and controls **MUST** remain readable, reachable, and usable at all **supported** text sizes (§3.5). |
| `NFR-A11Y-004` | MUST | Text **MUST NOT** become unintentionally clipped, overlapped, or otherwise inaccessible when it scales. |
| `NFR-A11Y-005` | MUST | Layouts **MUST** define adaptive behavior (reflow, wrap, stack, or scroll) when larger text no longer fits the original composition. |
| `NFR-A11Y-006` | MUST | Interactive controls **MUST** preserve appropriate touch targets (≥ **44×44 pt**) as text scales — including keypad keys, chips, the Review button, and the back button. |
| `NFR-A11Y-007` | SHOULD | Truncation or minimum-scale-factor behavior **SHOULD** be used only where it preserves meaning and usability; essential values MUST remain fully legible. |
| `NFR-A11Y-008` | MUST | The **large amount display** (GT Flexa 100 pt, design-spec §3) **MUST** have documented scaling behavior distinct from ordinary labels, because it already uses a **shrink-to-fit-width** rule (design-spec §10.7 / comment 7). The interaction between *content-driven* shrink-to-fit and *Dynamic-Type* growth is an explicit open consideration (§3.9). |
| `NFR-A11Y-009` | SHOULD | The keypad and amount region **SHOULD** remain functional at the largest accessibility sizes; if the full composition cannot fit, adaptive behavior (`NFR-A11Y-005`) MUST keep the keypad and the amount both reachable. |

### 3.5 Supported range
- **MUST** support the standard Dynamic Type range through the largest **standard** size, and **SHOULD** remain usable at the **accessibility** sizes (AX1–AX5).
- The precise minimum/maximum honored sizes and any clamping are a **FAD** (§3.9); clamping MUST NOT be used merely to avoid layout work (`NFR-A11Y-004`).

### 3.6 Engineering constraints
- No text may be rendered at a hard-coded, non-scaling size (`NFR-A11Y-001/002`), except where a documented exception applies (e.g., the amount display's own scaling model, `NFR-A11Y-008`).
- Touch targets are decoupled from glyph size so shrinking text does not shrink hit areas below 44×44 pt (`NFR-A11Y-006`; note design-spec §3.0 already flags keypad glyphs are smaller than their cells).

### 3.7 Acceptance criteria
- Changing the system text size visibly rescales labels (chips, `Review`, badge, any helper text) without clipping/overlap.
- At the largest accessibility size, the amount-entry screen keeps the keypad usable and the amount readable (via reflow/scroll/scale per `NFR-A11Y-005/008/009`).
- All interactive controls remain ≥ 44×44 pt at every supported size.
- Custom-font text scales, not just system-font text (`NFR-A11Y-002`).

### 3.8 Testing and validation considerations
- Exercise the screen across the Dynamic Type slider including AX sizes (Accessibility Inspector / Environment override).
- Verify no truncation of essential text and no overlap at extreme sizes.
- Verify touch-target sizes at min and max text sizes.
- Confirm custom fonts scale (compare against a system-font control).
- Validate the amount display's combined shrink-to-fit + Dynamic-Type behavior with both short (`$0`) and long (e.g., `$1,000,000`) values.

### 3.9 Unresolved decisions / assumptions (FAD)
- **FAD-A11Y-a:** scaling mechanism (semantic text styles vs. `@ScaledMetric`/`UIFontMetrics`) and how custom fonts register with it.
- **FAD-A11Y-b:** adaptive layout strategy at large sizes (reflow vs. scroll vs. alternate layout) and any breakpoints.
- **FAD-A11Y-c:** ⚠️ **amount-display scaling model** — reconciling the design's content-driven shrink-to-fit (comment 7) with Dynamic Type growth: does the amount honor Dynamic Type, its own fit rule, the larger of the two, or a capped combination? (design-spec §12 Q4.)
- **Assumption:** standard sizes are mandatory; AX sizes are strongly recommended and MUST NOT be actively broken.

---

## 4. Derived Functional Behaviors

> These are **directly observable behaviors that follow from the non-functional qualities above**. They are **derived functional behaviors, not separate product features**, and MUST NOT be tracked or scoped as new features.

- **DFB-1** — The app displays content in **English or Brazilian Portuguese** according to the device configuration (from `NFR-LOC-001/003/004`).
- **DFB-2** — The app updates its **appearance** according to the system **Light or Dark Mode** (from `NFR-THEME-001/002`).
- **DFB-3** — Text **changes size** according to the user's **Dynamic Type** setting (from `NFR-A11Y-001/002`).
- **DFB-4** — The interface **remains usable** after any of the above adaptations — no loss of content, controls, legibility, or touch targets (from `NFR-LOC-005`, `NFR-THEME-004`, `NFR-A11Y-004/006`).

---

## 5. Acceptance Matrix

Each row is a required validation combination. **PASS** requires: correct translation, correct locale formatting, correct appearance, legible contrast, no clipping/overlap, preserved hierarchy, and all controls usable with ≥ 44×44 pt touch targets. Validate on the amount-entry screen in **both** states (empty / filled).

| # | Language | Appearance | Text size | Must verify (visual + functional) |
|---|----------|-----------|-----------|-----------------------------------|
| 1 | English | Light | Default | Reference for Light re-theme; en copy; `$`/`,` per en policy; hierarchy preserved; contrast AA; no clipping. |
| 2 | English | Dark | Default | Matches Figma reference most closely; en copy; hierarchy & glows as designed; contrast AA. |
| 3 | pt-BR | Light | Default | pt-BR copy (longer strings) fits; grouping `2.000`; decimal/keypad per pt-BR (`NFR-LOC-011`); Light hierarchy preserved. |
| 4 | pt-BR | Dark | Default | pt-BR copy fits in the dark design; locale formatting; badge/`Review`/chips not truncated. |
| 5 | English | Light | Large accessibility (AX) | Text scales incl. custom fonts; keypad & amount usable; touch targets ≥ 44 pt; no overlap; amount scaling model behaves (`NFR-A11Y-008`). |
| 6 | English | Dark | Large accessibility (AX) | Same as #5 in Dark; glows/contrast still legible at large text. |
| 7 | pt-BR | Light | Large accessibility (AX) | Longest case: pt-BR + big text in Light — worst-case expansion; adaptive layout keeps content reachable; nothing clipped. |
| 8 | pt-BR | Dark | Large accessibility (AX) | pt-BR + big text in Dark; verify amount, chips, `Review`, badge, and keypad all remain usable and legible. |

**Cross-cutting checks for every row:** VoiceOver reads localized labels/values; no essential info conveyed by color alone; live switching of language/appearance/text-size does not break the layout; fallback behaves for unsupported languages.

---

## 6. Open Questions Summary (consolidated)

| Ref | Area | Question |
|-----|------|----------|
| ⚠️ FAD-LOC-c | Loc | Is currency fixed USD or locale-derived? Symbol position? Decimal places? (design-spec §12 Q1) |
| ⚠️ FAD-LOC-d | Loc | Decimal separator/keypad glyph coupling to locale (`.` vs `,`). |
| ⚠️ FAD-THEME-a | Theme | Light Mode palette — no Figma source exists; must be derived/approved. |
| ⚠️ FAD-A11Y-c | A11y | How does the amount's shrink-to-fit interact with Dynamic Type? (design-spec §12 Q4) |

*All requirement IDs (`NFR-LOC-*`, `NFR-THEME-*`, `NFR-A11Y-*`) are stable and may be referenced by future architecture, implementation, and test documents. This document defines requirements only; no production code is affected.*
