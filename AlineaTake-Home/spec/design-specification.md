# Alinea — Amount Entry Screen · Design Specification

> **Scope of this document:** visual design, layout, assets, and observable/commented interaction behavior only.
> It intentionally does **not** define SwiftUI architecture, state management, data layer, navigation, or concrete implementation — those are covered separately.
>
> **Source of truth:** Figma (editable copy) `MszGJ6kmpBwJoFyELIFOTA` — *Alinea Frontend Take-home (Copy)*.
> All values marked **[C]** were read directly from the Figma MCP (`get_metadata`, `get_design_context`, `get_variable_defs`, `get_screenshot`). **[I]** = inferred from the design. **[A]** = assumption requiring confirmation. See §11–§12.

---

## 1. Design Overview

A single **amount-entry screen** for the Alinea app, rendered in a dark theme on an iPhone-class device. The user enters a monetary amount with an on-screen numeric keypad; the large amount display updates live. Two sample states are provided in Figma:

- **State A — Empty:** faint `$0` placeholder + blinking caret, three quick-amount **suggestion bubbles**, full keypad.
- **State B — Filled:** bright `$2,000` amount, a glowing **Review** button (the suggestion bubbles are gone), full keypad.

The two states share the status bar, back button, `AUTOMATED` badge, keypad, and home indicator. The only region that differs is the **action band** (~y470–516): suggestion bubbles in State A ↔ Review button in State B, and the **amount treatment** (faint placeholder vs. bright gradient value).

**Product-requirement comments** attached in Figma (treated as requirements, see §10):
1. Suggestion bubbles show only when no amount is entered.
2. The Review button's border gradient is **animated** (effect open-ended).
3. The bubbles→button change is an **animated transition** (open-ended).
4. Every keypad key gives **haptic feedback**.
5. The amount **caret blinks** and always sits at the **end** of the entered value.
6. The **decimal key is disabled** when a decimal separator would be invalid (states to be identified, rules **not** to be invented).
7. The **amount text scales down** when too wide for the screen.
8. The amount **animates** on any change (insert/remove digit; open-ended).

**Design environment [C]:** `dark / foreground = #FFFFFF`; frame background `#18161F`.

---

## 2. Screens and States Inventory

| # | State | Figma node | Frame size | Distinguishing content |
|---|-------|-----------|-----------|------------------------|
| A | Empty / placeholder | `1:319` ("Frame") | 393 × 853 | Faint `$0` + caret; 3 suggestion bubbles (`$500`, `$2,000`, `$10,000`); keypad |
| B | Filled / `$2,000` | `1:358` ("Frame") | 393 × 853 | Bright `$2,000`; glowing white **Review** button; keypad; top glow ellipse |
| — | Instructions note | `1:465` | (canvas note) | Take-home instructions text (not part of the app UI) |

**States implied but not drawn** (see §12): key **pressed/highlighted**, chip **pressed/selected**, decimal **disabled**, Review **pressed**, back **pressed**, caret in filled state, very-long-amount (scaled) layout, loading. None of these are visually specified in Figma.

**Device reference [C/I]:** 393 × 852 pt logical (iPhone 14/15/16 Pro class). Status bar 47 pt, home indicator 34 pt. Portrait only (only orientation shown).

---

## 3. Screen-by-Screen Specifications

Coordinates below are **absolute within the 393 × 852 device frame** unless noted. Origin = top-left. All numeric values are **[C]** from Figma unless tagged otherwise.

### 3.0 Shared chrome (both states)

**Status bar** (`StatusBar` instance `1:320` / `1:360`)
- Frame: x 0, y 1, 393 × 47.
- Time `9:41`: SF Pro Text Semibold 16, line-height 21, tracking −0.32, white, centered in a 54-wide slot on the left (left cluster centered ≈ x 55).
- Right cluster (signal / Wi-Fi / battery): image asset, 77.4 × 13, top 19, right-aligned (left ≈ x 315).

**Back button** (`Frame 838` `1:350` / `1:379`)
- Box: 36 × 36, left **18.21**, top **74.35** (State A) / **75.35** (State B).  *(1 px vertical delta between states — see §12.)*
- Container: corner radius **25.988** (≈ circular), `backdrop-blur 11.25`, `overflow: clip`.
- Icon: `chevron_12` chevron-left, 24 × 24, white, inset 6 from top/right of the 36-box. Rendered via rotate/flip in Figma; visually a left chevron.
- Asset: `imgChevron12` (per-state export).

**"AUTOMATED" badge** (`Frame 6930` `1:352` / `1:404` → `Frame 6852` image)
- Box: **95 × 20**, horizontally centered (left ≈ 149), top **81.05**.
- Appearance: dark translucent pill with a **thin magenta→blue gradient border** and white **uppercase, condensed** label `AUTOMATED`. Delivered as a flattened image asset (`imgFrame6852`); exact border width and internal padding are baked into the PNG.

**Keypad** (`Group` `1:325` / `1:365`; container group `1:321` / `1:361`)
- Layout: **3 columns × 4 rows**. Column horizontal centers ≈ **x 59 / 189 / 320**. Row text-top positions ≈ **y 562 / 630 / 698 / 766**; row pitch ≈ **68**.
- Keys by cell:
  | | Col 1 (x≈59) | Col 2 (x≈189) | Col 3 (x≈320) |
  |---|---|---|---|
  | Row 1 (y≈562) | `1` | `2` | `3` |
  | Row 2 (y≈630) | `4` | `5` | `6` |
  | Row 3 (y≈698) | `7` | `8` | `9` |
  | Row 4 (y≈766) | `.` | `0` | ⌫ backspace |
- Digit glyphs: **SF Pro Medium (weight 510), 36.647 px, tracking −1.0994**, white, centered. Glyph box height 42.335. (Per-glyph widths vary 9–25 px; centers are the reliable anchor.)
- Backspace (`Icons` `1:322` / `1:362`): image asset (`imgIcons`), **51.095 × 46.593**, centered ≈ **(321, 790)** — column 3 / row 4. Visual: a semi-transparent rounded key bearing a `⌫`/`×` delete glyph.
- **Touch targets [I]:** glyphs are small; tappable cells should span the full column/row pitch (≈ 131 wide × 68 tall) for a usable keypad. Exact hit-rects are not defined in Figma.

**Home indicator** (`tab bar / home indicator` `1:337` / `1:377`)
- 393 × 34 at bottom, **opacity 12%**. White bar 135 × 5, radius 100, 8 pt from bottom, centered.

### 3.1 State A — Empty (`1:319`)

- **Background:** solid `#18161F`, frame radius 16 (frame is clipped; radius irrelevant on full-bleed device but present).
- **Amount placeholder** (`Group 2085665203` `1:346`)
  - `$0` text (`1:348`): **GT Flexa "Condensed Medium", 100 px, line-height = 1.0 (leading-none), tracking −2**, centered. Color = white @ 40% **and** layer opacity 10% → effective ≈ 4% white (very faint grey). Text box 105 wide, top 255.15.
  - **Caret** (`1:349`): solid **white** rounded bar, **3.033 × 106.486**, radius 100, at left 197.22 / top 255.5 (immediately trailing the placeholder, vertically spanning the glyph). This is the blinking end-caret (§10.5).
- **Suggestion bubbles** (`Group 1321315729` `1:338`)
  - Row container: left **41**, top **472.5**, **311 × 44**, horizontally centered.
  - Three pill chips, left→right: `$500` (96 wide), `$2,000` (96), `$10,000` (95). **Gap 12** between chips.
  - Chip style: fill `rgba(35,33,44,0.75)` (= `#23212C` @ 75%), height 44, corner radius **121** (full pill), `overflow: clip`, no visible border.
  - Chip label: **Instrument Sans SemiCondensed Medium, 17 px, tracking −0.17**, white, centered.
- No Review button in this state.

### 3.2 State B — Filled (`1:358`)

- **Background:** `#18161F` + a **top glow ellipse** (`Ellipse 1292` `1:359`, image `imgEllipse1292`): 519 × 519, horizontally centered, top −272.8 (mostly off-screen above), producing a soft brand-tinted glow behind the amount. Subtle.
- **Amount value** (`$2,000` text `1:378`)
  - **GT Flexa "Condensed Medium", 100 px, line-height 1.0, tracking −2**, centered. Text box **280 × 100**, top **253.15**, centered (left ≈ 56).
  - Fill: a near-white **radial gradient** (`rgba(255,255,255,1)` → `rgba(255,255,255,0.8)`) at ~90% opacity — reads as bright white with a subtle sheen. (Contrast State A's ~4% faint placeholder.)
  - Thousands separator: comma present (`$2,000`). No caret drawn in this static frame (see §12).
- **Review button** (`Frame 2147217307` `1:381`) — composited from three layers:
  1. **Gradient border/halo** (container `1:381`): linear gradient **`#B24DCC` → `#8955F9`** (left→right), 345 × 50, radius 1000, centered, vertical center ≈ y 495 (top ≈ 470). This is the layer the "animated border gradient" comment targets (§10.2).
  2. **Multicolor glow** (`Frame 2085664808` `1:383` → `allie`/`orb` group `1:387`): blurred rainbow orb + gloss (`imgOrb`, `imgAllie` mask, `imgEllipse1283`, `imgRectangle921252`, `imgGroup1073713937`, gloss vectors `imgRectangle240649731/732`) creating the soft glowing spill beneath/around the pill.
  3. **White pill** (`Frame` `1:399`): fill **`#FFFFFF`**, **347 × 48**, radius **29.869**, drop-shadow `0 0 4.726 rgba(255,255,255,0.1)`. Label `Review`: **GT Flexa "Condensed Medium", 21.267 px, tracking −0.638**, color **`#22212D`**, centered. *(A second white 24 px "Review" label `1:382` sits on the gradient layer beneath the pill and is not the visible one — see §12.)*
  - Net appearance: a solid **white** pill with dark `Review` text, wrapped in a glowing magenta→purple gradient halo.
- No suggestion bubbles in this state.

---

## 4. Typography

| Role | Family / style | Size | Line height | Tracking | Case | Align | Color | Where |
|------|----------------|------|-------------|----------|------|-------|-------|-------|
| Amount (display) | **GT Flexa**, Condensed Medium (500) | **100** | 1.0 | **−2** | — | center | State A: white 40% @ 10% op · State B: white radial gradient ~90% | `$0` / `$2,000` |
| Review label (rendered) | GT Flexa, Condensed Medium | **21.267** | normal | −0.638 | Title | center | `#22212D` | `1:401` |
| Review label (token "Title 2 Medium") | GT Flexa, Condensed Medium | **24** | 100 (=1.0) | **−3** | Title | center | white | token / `1:382` |
| Keypad digits | **SF Pro**, Medium (510) | **36.647** | normal | −1.0994 | — | center | `#FFFFFF` | `1:325`/`1:365` |
| Suggestion chip | **Instrument Sans SemiCondensed**, Medium | **17** | normal | −0.17 | — | center | `#FFFFFF` | chips |
| Status bar time | **SF Pro Text**, Semibold | 16 | 21 | −0.32 | — | center | `#FFFFFF` | `9:41` |
| `AUTOMATED` badge | (baked into image asset — condensed uppercase) | ~small | — | — | UPPER | center | white | badge PNG |

**Fonts required [C]:** `GT Flexa` (Condensed Medium), `SF Pro` / `SF Pro Text` (system), `Instrument Sans SemiCondensed`. **GT Flexa and Instrument Sans SemiCondensed are non-system fonts** — bundling/licensing is an open question (§12). `text-[510]`/weight 510 is SF Pro's "Medium" optical weight.

**Design token surfaced [C]:** `Title 2 Medium = GT Flexa / Condensed Medium / 24 / lh 100 / tracking −3`. Note the rendered Review label (21.267, −0.638) is a scaled instance of this token, not an exact match (§12).

---

## 5. Colors and Visual Effects

### Colors (variables `[C]`)
| Token | Value | Usage observed |
|-------|-------|----------------|
| `dark / foreground` | `#FFFFFF` | Primary text, keypad, caret |
| `main/white` | `#FFFFFF` | Review pill fill, amount |
| `main/brand` | `#B24DCC` | Review gradient start; badge border |
| `strategies/st01` | `#8955F9` | Review gradient end |
| `strategies/st03` | `#2073DF` | Part of brand gradient palette (blue) |
| `main/accent` | `#FFEE59` | Defined in system; **not visibly used** on these screens |
| `core/brandGradient` | (gradient token; value not resolved by MCP) | Badge border, Review halo |
| Background | `#18161F` | Screen background (literal, not a named var) |
| Chip fill | `rgba(35,33,44,0.75)` = `#23212C` @75% | Suggestion bubbles |
| Amount value fill | radial `#FFFFFF`→`rgba(255,255,255,0.8)` @~90% | State B `$2,000` |
| Amount placeholder | white @40% × layer-opacity 10% | State A `$0` |
| Review label | `#22212D` | Dark text on white pill |

### Effects `[C]`
- **Review pill shadow:** `0 0 4.726 rgba(255,255,255,0.1)` (soft white bloom).
- **Review halo/glow:** magenta→purple gradient border + blurred rainbow orb group behind the pill (multi-asset composite).
- **Back button:** `backdrop-blur 11.25` over a ~circular (r 25.988) clip.
- **Top glow ellipse (State B):** large 519 px soft radial glow above the amount.
- **Home indicator:** layer opacity 12%.
- **Corner radii:** frame 16 · chips 121 (pill) · Review outer 1000 (pill) · Review white pill 29.869 · back button 25.988 · caret 100 · home bar 100.

---

## 6. Spacing and Layout Rules

**Vertical rhythm (device-absolute y) `[C]`:**
| Element | Top | Size |
|---|---|---|
| Status bar | 1 | 47 |
| Back button | 74.35 / 75.35 | 36 |
| `AUTOMATED` badge | 81.05 | 20 |
| Amount block | 253–255 | ~100–107 |
| Action band (bubbles / Review) | 470–472.5 | 44 / 50 |
| Keypad row 1 → row 4 | 562 → ~766 | pitch ≈ 68 |
| Backspace center | ~790 | 51 × 47 |
| Home indicator | 818 | 34 |

**Horizontal margins `[C/I]`:**
- Review button: **24 pt** side margin ((393−345)/2). **[C]**
- Suggestion-bubble row: **41 pt** side margin (left 41, width 311). **[C]** *(Bubble row is inset more than the Review button — see §12.)*
- Keypad: symmetric; outer column centers at x 59 and 320 (≈ 59 pt inset to first column center). **[C]**
- Back button: 18.21 pt from left. **[C]**
- Amount: centered; State B value box 280 wide (≈ 56 pt side margin at `$2,000`). **[C]**

**Grid/gap `[C]`:** chip gap 12; keypad column pitch ≈ 130.5, row pitch ≈ 68.

**Safe areas `[I]`:** content respects a ~47 pt top (status bar) and 34 pt bottom (home indicator) inset. No element overlaps them.

---

## 7. Assets and Icons

All served as flattened exports from Figma MCP (URLs expire ~7 days; re-export or recreate for production).

| Asset | Node | Size | Notes |
|-------|------|------|-------|
| Back chevron | `chevron_12` `1:351/1:380` | 24×24 | Left chevron, white. Replaceable with SF Symbol `chevron.left` **[I]**. |
| `AUTOMATED` badge | `Frame 6852` `1:353/1:405` | 95×20 | Dark pill, gradient border, white condensed uppercase text. **Recommend rebuilding as a live view** (gradient-stroke capsule + text) rather than shipping the PNG **[I]**. |
| Backspace key | `Icons` `1:322/1:362` | 51×47 | Semi-transparent rounded key with delete `⌫`/`×` glyph. Could be SF Symbol `delete.left` **[I]**. |
| Status-bar right cluster | `Right Side` | 77.4×13 | Signal/Wi-Fi/battery. Use the system status bar in production **[I]**. |
| Top glow ellipse (State B) | `Ellipse 1292` `1:359` | 519×519 | Soft radial background glow. |
| Review glow composite | `1:383` subtree (`orb`, `allie`, ellipses, gloss vectors) | ~345 band | Blurred multicolor halo + gloss behind the white pill. Recreate with gradients/blur for animation **[I]**. |

**Icon inventory:** back chevron, backspace/delete, status-bar glyphs. No other icons.

---

## 8. Potential Design Tokens

Candidates for a small project design system (identification only — not yet implemented):

**Color**
- `color/bg` = `#18161F`
- `color/foreground` = `#FFFFFF` (`main/white`, `dark/foreground`)
- `color/brand` = `#B24DCC` (`main/brand`)
- `color/brand-2` = `#8955F9` (`strategies/st01`)
- `color/brand-3` = `#2073DF` (`strategies/st03`)
- `color/accent` = `#FFEE59` (`main/accent`, unused here)
- `color/surface-chip` = `#23212C` @75%
- `color/on-brand-pill` = `#22212D`
- `gradient/brand` = `core/brandGradient` (magenta→purple→blue); linear `#B24DCC→#8955F9` used on the Review pill

**Typography**
- `type/display` = GT Flexa Condensed Medium 100 / lh 1.0 / −2 (amount)
- `type/title-2` = GT Flexa Condensed Medium 24 / lh 1.0 / −3 (Review, token "Title 2 Medium")
- `type/keypad` = SF Pro Medium 36.647 / −1.0994
- `type/chip` = Instrument Sans SemiCondensed Medium 17 / −0.17

**Radius**
- `radius/frame` 16 · `radius/pill` 999 (chips 121, button 1000) · `radius/pill-inner` ~30 (Review white pill 29.869) · `radius/control` ~26 (back button)

**Spacing / sizing**
- `space/chip-gap` 12 · `size/chip-h` 44 · `size/button-h` 48–50 · `size/control` 36 · `keypad/row-pitch` 68 · `margin/side` {24 button, 41 chips}

**Effect**
- `shadow/pill-bloom` = `0 0 4.726 rgba(255,255,255,0.1)`
- `blur/control-backdrop` = 11.25

> Note: the file mixes **named variables** (colors, `Title 2 Medium`) with **one-off literals** (background, chip fill, radii). Only the named ones are confirmed design-system tokens; the rest are candidates.

---

## 9. Potential Reusable Components

| Component | Appears in | Constant props | Variations | Configurable | Reuse support |
|-----------|-----------|----------------|------------|--------------|---------------|
| **KeypadKey** | 12× per state, both states | 36.647 SF Pro Medium white, centered, column/row pitch | digit vs `.` vs backspace(icon); pressed/disabled (not drawn) | label/icon, enabled, onPress(haptic) | **Strong** — literal 12× repetition |
| **SuggestionChip** | 3× (State A) | pill r121, fill #23212C@75%, h44, Instrument Sans 17 white | width fits label; selected/pressed (not drawn) | label, value, width, onTap | **Strong** — 3× repetition |
| **GradientBorderPill / PrimaryButton** | Review (State B); shares pill idiom with chips & badge | pill shape, gradient border, centered label | animated gradient; glow intensity | label, gradient, glow, onTap | **Medium** — one instance, but a clear pattern |
| **AmountDisplay** | both states | GT Flexa 100, centered, comma grouping | placeholder(faint) vs value(gradient); caret on/off; auto-scale | text, isPlaceholder, showCaret | **Strong** — same element, two states |
| **BlinkingCaret** | State A (and end of value at runtime) | white bar 3×~106, r100 | height tracks font scale | visible/blink | **Medium** — one static instance, but comment-mandated everywhere |
| **CircularControl (back)** | back button both states | 36, r~26, backdrop-blur 11.25 | icon | icon, onTap | **Medium** — single use |
| **GradientBorderBadge (AUTOMATED)** | badge both states | pill, gradient border, condensed uppercase | text | text | **Tentative** — currently a PNG; component only if rebuilt |
| **StatusBar / HomeIndicator** | both states | system chrome | — | — | Use system equivalents; low reuse value |

**Shared idiom [I]:** the gradient-bordered pill recurs (Review button, `AUTOMATED` badge) — a strong case for one `GradientBorderContainer` primitive with a `brandGradient` token.

---

## 10. Interaction and Scrolling Behavior

**Scrolling:** none. The screen is a **fixed, non-scrolling** full-device layout; keypad is pinned to the bottom, amount to the upper third. No scroll views, no safe-area scrolling. **[I]**

**Instruction note (requirements) [C]:** keypad must be fully functional and update the amount; back button and Review button are tappable but perform **no action**; "pay attention to the comments."

**Commented requirements (product spec) [C]:**
1. **Suggestion bubble visibility** (`1:342`/`1:338`): bubbles are shown **only when no amount has been entered**. Once an amount exists, they are hidden (replaced by the Review button).
2. **Animated border gradient** (`1:381`): the Review button's border gradient must **animate**; specific motion is open-ended (propose an appropriate effect, e.g. rotating/traveling gradient).
3. **Bubbles → button transition** (`1:338`): the swap from suggestion bubbles to the Review button must be **animated**; specific transition open-ended.
4. **Keypad haptics:** every keypad key fires **haptic feedback** on press.
5. **Amount caret** (`1:346`): the caret **blinks** and is **always at the end** of the entered amount (both empty and filled states).
6. **Decimal key state** (`1:321`/`1:333` = `.`): the `.` key is **disabled** when entering a decimal separator would be invalid/inappropriate. Identify candidate states (§12); **do not invent** unstated business rules.
7. **Amount auto-scaling** (`1:378`): the amount text **shrinks to fit** the available screen width when it grows too large.
8. **Digit-editing animation** (`1:346`): the amount **animates on every change** (digit inserted or removed); specific animation open-ended.

**Observable state differences (A↔B) [C]:** amount opacity/fill (faint↔bright-gradient); action band (bubbles↔Review); back-button y (+1 px). Everything else is identical.

**Not specified (inferred/assumed):** key-press highlight, chip-tap behavior (§12), Review/back pressed styling, caret rendering in filled state, disabled-decimal styling, max length/scaled layout. **[I/A]**

---

## 11. Confirmed Values, Inferences, and Assumptions

**Confirmed [C]** — read from Figma MCP:
- Two frames/states, all node IDs, sizes, positions listed in §2–§6.
- All typography (family/size/tracking/lh), colors/variables (§4–§5), radii, effects, asset dimensions.
- Frame 393×853; status bar 47; home indicator 34; keypad grid; chip/button geometry; comment text (§10).

**Inferred [I]** — reasoned from the design, not explicitly stated:
- Reference device 393×852 pt (iPhone Pro class), portrait only.
- Screen is fixed/non-scrolling; keypad pinned bottom.
- State A = empty entry; State B = a representative filled value.
- Keypad tappable cells span the full column/row pitch (glyphs are only the visible centers).
- Back chevron / backspace / status bar are replaceable with system equivalents.
- The gradient halo layer (`1:381`) is the element the "animated border" comment refers to.
- Caret should also render at the end of the value in filled state (comment says "always"), though State B's static frame omits it.

**Assumptions requiring confirmation [A]** (see §12 for questions):
- Tapping a suggestion chip sets the amount to that value.
- Currency is always USD with a leading `$`; grouping uses commas (thousands). Decimal-place rules unknown.
- Placeholder `$0` is replaced (not prefixed) once typing begins.
- Max amount / max digit count / scaling threshold.
- Exact decimal-disable rules (candidate states only, per comment 6).

---

## 12. Ambiguities and Open Questions

1. **Decimal key disable rules (comment 6, explicit "don't invent").** Candidate states to disable `.`: (a) a `.` already exists in the amount; (b) amount is empty / only placeholder; (c) after two decimal places already entered. **Which rules apply? Is there a fixed decimal-place limit (currency = 2)?** — needs product answer.
2. **Suggestion-chip tap behavior.** Chips are "suggestions" and disappear once an amount is entered — strongly implying **tap = set amount**. Confirm, and whether a tapped chip has a selected/pressed visual (none drawn).
3. **Caret in filled state.** Comment 5 says the caret is *always* at the end, but State B's frame shows no caret. Confirm it should blink at the end of `$2,000` too.
4. **Amount scaling threshold (comment 7).** At 100 px, `$2,000` (280 wide) fits within 393. **At what width does it start scaling, and to what minimum size?** Not specified.
5. **Two "Review" labels.** The white pill shows dark text at **21.267 px**, while a hidden white label + the `Title 2 Medium` token specify **24 px / tracking −3**. Which is canonical for implementation? (Recommend the token 24/−3, scaled to fit.) The rendered 21.267/−0.638 looks like a scaled instance.
6. **Side-margin inconsistency.** Suggestion bubbles inset 41 pt; Review button insets 24 pt. Both occupy the same band. Intentional, or should the Review button match the bubble row width? Confirm.
7. **Back-button 1 px y shift** (74.35 vs 75.35) between states — assumed a rounding artifact, treat as one position.
8. **`AUTOMATED` badge internals.** Delivered as a PNG; exact border width, padding, and font are baked in. Rebuild as a live gradient-stroke capsule? Confirm the label is static text.
9. **`core/brandGradient` stops/direction.** MCP returned an empty value for the gradient token; the Review pill resolves to linear `#B24DCC→#8955F9`, but the full brand-gradient definition (incl. `#2073DF`, and whether it's angular for the animated border) is unconfirmed.
10. **Unused `main/accent` (`#FFEE59`).** Present in the system but not on these screens — is it needed for any state (e.g., error/validation)?
11. **Fonts.** `GT Flexa` and `Instrument Sans SemiCondensed` are non-system. Are licensed font files available to bundle, or should substitutes be used?
12. **Empty/zero submission.** Is Review shown at `$0`? (Design shows Review only in the filled state; behavior for `$0` after deletion is unspecified.)

---

## 13. Pixel-Perfect Validation Checklist

Background & chrome
- [ ] Background exactly `#18161F`.
- [ ] Status bar time `9:41`, SF Pro Text Semibold 16 / −0.32.
- [ ] Back button 36×36 at (18, 74), ~circular, backdrop-blur, white left chevron.
- [ ] `AUTOMATED` badge 95×20, centered, top 81, gradient-bordered pill, white condensed uppercase.
- [ ] Home indicator bar 135×5 @12% opacity, 8 pt from bottom.

Amount
- [ ] GT Flexa Condensed Medium 100 px, tracking −2, centered.
- [ ] State A: faint `$0` (~4% white) + white caret bar 3×106 (r100) blinking at end.
- [ ] State B: bright white/gradient value, comma grouping (`$2,000`), top ≈ 253.
- [ ] Amount scales down when too wide (comment 7).
- [ ] Amount animates on digit change (comment 8).

Action band
- [ ] State A: 3 chips `$500 / $2,000 / $10,000`, each 44 tall, r-pill, fill #23212C@75%, gap 12, row centered at top 472.5, side margin 41.
- [ ] Chip label Instrument Sans SemiCondensed Medium 17 / −0.17.
- [ ] State B: Review pill 345×50 (white pill 347×48, r≈30), dark `#22212D` label, gradient border `#B24DCC→#8955F9`, glow halo, side margin 24, top ≈ 470.
- [ ] Border gradient animates (comment 2); bubbles↔button transition animates (comment 3).
- [ ] Bubbles present iff amount empty (comment 1).

Keypad
- [ ] 3×4 grid; column centers 59/189/320; row tops 562/630/698/766; pitch 68.
- [ ] Digits SF Pro Medium 36.647 / −1.0994, white, centered.
- [ ] Row 4 = `.`, `0`, backspace; backspace ~51×47 at (321, 790).
- [ ] Decimal key disables per confirmed rules (comment 6).
- [ ] Every key fires haptic on press (comment 4).

Cross-checks
- [ ] Only the action band + amount treatment differ between A and B; all shared chrome pixel-identical.
- [ ] No scrolling; fixed layout; safe-area insets respected (47 top / 34 bottom).
- [ ] Fonts render (GT Flexa, Instrument Sans SemiCondensed, SF Pro) or approved fallbacks.

---

*Prepared from Figma MCP inspection of the editable copy (`MszGJ6kmpBwJoFyELIFOTA`), cross-checked against `get_design_context` screenshots for both states. Values without a tag are Confirmed [C].*
