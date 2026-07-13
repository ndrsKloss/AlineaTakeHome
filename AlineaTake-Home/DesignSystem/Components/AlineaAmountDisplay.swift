import SwiftUI

/// The amount display (arch-spec §10 `AmountDisplay`; Figma `2010:549` empty /
/// `2010:550` filled): the large centered value at the top of the Amount screen.
/// Borderless free-standing text (design-spec §3) — no field chrome.
///
/// Presentation only. The caller passes an already-formatted amount string and
/// tells the display whether it's the faint placeholder and whether to show the
/// trailing caret; the amount value, locale formatting, and caret/placeholder
/// rules are owned by the view model (design-spec §10.5, §12).
///
/// The component *declares* its transitions — value edits blur-crossfade the
/// whole value (old value blurs + fades out while the new one blurs in), and
/// the placeholder ⇄ filled branches crossfade via `.transition(.opacity)` —
/// but plays them only when the caller mutates the value inside an animated
/// transaction (`withAnimation`, owned by `AmountEntryView`, which also gates
/// it on Reduce Motion). An ancestor `.animation(_:value:)` proved unreliable
/// for the branch swap, hence the explicit-transaction design.
struct AlineaAmountDisplay: View {
    private let text: String
    private let isPlaceholder: Bool
    private let showCaret: Bool
    private let accessibilityLabel: String?
    private let languageIdentifier: String?

    /// - Parameters:
    ///   - text: The pre-formatted amount (e.g. `"$0"`, `"$2,000"`). Verbatim —
    ///     grouping/locale is the caller's job (`NFR-LOC`), like `AlineaChip`.
    ///   - isPlaceholder: Faint placeholder treatment (empty state) vs the bright
    ///     value fill (filled state).
    ///   - showCaret: Whether the blinking end-caret trails the value
    ///     (design-spec §10.5; filled-state caret is caller's call — §12 Q3).
    ///   - accessibilityLabel: Optional VoiceOver reading. When `nil`, the
    ///     verbatim `text` is spoken; callers pass a natural spoken currency
    ///     phrase (e.g. "2.000 reais brasileiros") so VoiceOver doesn't read the
    ///     raw symbol string (`NFR-LOC-009`).
    ///   - languageIdentifier: Optional BCP-47 tag (e.g. `"pt-BR"`) so VoiceOver
    ///     pronounces the label in the content language regardless of the global
    ///     voice (`NFR-LOC-009`). `nil` ⇒ the global voice, as before.
    init(
        _ text: String,
        isPlaceholder: Bool,
        showCaret: Bool = false,
        accessibilityLabel: String? = nil,
        languageIdentifier: String? = nil
    ) {
        self.text = text
        self.isPlaceholder = isPlaceholder
        self.showCaret = showCaret
        self.accessibilityLabel = accessibilityLabel
        self.languageIdentifier = languageIdentifier
    }

    var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text.spoken(accessibilityLabel ?? text, language: languageIdentifier))
            .accessibilityIdentifier("amountDisplay")
    }

    @ViewBuilder
    private var content: some View {
        if showCaret, isPlaceholder, let firstDigit = text.firstIndex(where: \.isNumber) {
            // Empty state renders the caret on the boundary between the
            // currency symbol and the placeholder zero, hugging the zero from
            // the symbol's side: a *prefix* symbol puts the caret before the
            // digits ("$|0", "R$|0"); a *suffix* symbol puts it after them
            // ("0|€"). The design pins the caret at the frame's horizontal
            // centre (design-spec §3.1: caret at x≈197 ≈ 393/2), *not* the
            // amount block — for a wide symbol like BRL's "R$" a centred block
            // would still push the caret off to the right. Two equal
            // `maxWidth: .infinity` halves share the space around the
            // fixed-width caret, so it stays dead-centre for any symbol width:
            // `lead` hugs it from the left, `value` from the right.
            //
            // Prefix vs suffix is detected by whether any non-whitespace char
            // precedes the first digit. The split falls on the symbol↔number
            // boundary either way, and its surrounding whitespace is trimmed —
            // so the currency's own separator (`.whitespaces` includes the
            // no-break space, e.g. the `\u{00A0}` in `R$ 0` or `0\u{00A0}€`) is
            // replaced by a symmetric `midCaretGap` on both sides of the caret.
            let hasPrefixSymbol = text[..<firstDigit].contains { !$0.isWhitespace }
            let split = hasPrefixSymbol
                ? firstDigit
                : (text[firstDigit...].firstIndex { !$0.isNumber } ?? text.endIndex)
            let lead = String(text[..<split]).trimmingCharacters(in: .whitespaces)
            let value = String(text[split...]).trimmingCharacters(in: .whitespaces)
            HStack(spacing: Layout.midCaretGap) {
                glyphs(lead).frame(maxWidth: .infinity, alignment: .trailing)
                AmountCaret()
                glyphs(value).frame(maxWidth: .infinity, alignment: .leading)
            }
            .transition(.opacity)
        } else {
            // Filled (or no caret): the caret trails the value.
            HStack(spacing: Layout.caretGap) {
                glyphs(text)
                if showCaret {
                    AmountCaret()
                }
            }
            .transition(.opacity)
        }
    }

    private func glyphs(_ string: String) -> some View {
        // Blur-crossfade the whole value on edits: `.id` swaps the view
        // identity per string, so the outgoing value blurs + fades out while
        // the incoming one blurs in. The animation transaction is owned by
        // `AmountEntryView` (its `withAnimation` also gates Reduce Motion).
        glyphText(string)
            .foregroundStyle(valueFill)
            .transition(Self.valueSwap)
            .id(string)
    }

    /// The value-edit transition: opacity combined with a soft blur, so a
    /// change reads as the old value dissolving into the new one rather than
    /// a hard swap.
    private static let valueSwap: AnyTransition = .opacity.combined(
        with: .modifier(
            active: BlurModifier(radius: Layout.editBlurRadius),
            identity: BlurModifier(radius: 0)
        )
    )

    /// The display-styled amount text: the §10.7 long-amount shrink
    /// (`minimumScaleFactor`) keeps very wide values on one line.
    private func glyphText(_ string: String) -> some View {
        Text(verbatim: string)
            .textStyle(.display)
            .lineLimit(1)
            .minimumScaleFactor(Layout.minScale) // shrink long amounts (design-spec §10.7)
    }

    /// Placeholder → the faint ghost role; filled → the design's near-white radial
    /// sheen composed from the adaptive `amountValue` token.
    private var valueFill: AnyShapeStyle {
        if isPlaceholder {
            AnyShapeStyle(Color.textPlaceholder)
        } else {
            AnyShapeStyle(
                RadialGradient(
                    colors: [Color.amountValue, Color.amountValue.opacity(0.8)],
                    center: .center,
                    startRadius: 0,
                    endRadius: Layout.valueSheenRadius
                )
            )
        }
    }
}

/// Blurs its content — the animatable half of the value-edit transition
/// (`AnyTransition.modifier` needs a `ViewModifier` pair to interpolate).
private struct BlurModifier: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }
}

/// The blinking caret: a solid rounded bar at the insertion point (design-spec
/// §3.1 / §10.5, ~3 × ~100, radius 100) — between the symbol and the placeholder
/// zero when empty (`$|0`), trailing once a value is entered. Owns its blink;
/// steady under Reduce Motion (`NFR-A11Y`). Decorative — hidden from VoiceOver
/// (the parent reads the value).
private struct AmountCaret: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = true

    var body: some View {
        Capsule()
            .fill(Color.textPrimary)
            .frame(width: Layout.caretWidth, height: Layout.caretHeight)
            .opacity(isVisible ? 1 : 0)
            .onAppear(perform: startBlink)
            .accessibilityHidden(true)
    }

    private func startBlink() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: Layout.caretBlinkDuration).repeatForever()) {
            isVisible = false
        }
    }
}

private enum Layout {
    /// Gap between the value and the trailing caret.
    static let caretGap: CGFloat = 4
    /// Tight gap around the placeholder's mid-caret ("$|0").
    static let midCaretGap: CGFloat = 2
    /// Caret bar width (design-spec §3.1, ~3.033).
    static let caretWidth: CGFloat = 3
    /// Caret bar height (design-spec §3.1, ~106.486 ≈ the 100pt display line).
    static let caretHeight: CGFloat = 100
    /// Half-cycle of the caret blink.
    static let caretBlinkDuration: TimeInterval = 0.5
    /// Minimum shrink for very long amounts. The exact threshold is unspecified
    /// (design-spec §10.7 / `FAD-A11Y-c`); 0.4 keeps large values on one line.
    static let minScale: CGFloat = 0.4
    /// Radius of the value's radial sheen — wide enough to span the display line.
    static let valueSheenRadius: CGFloat = 200
    /// Peak blur of the value-edit crossfade — soft enough to read as a
    /// dissolve at the 100pt display size without smearing across the screen.
    static let editBlurRadius: CGFloat = 10
}

#Preview("Dark") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: .spacingLarge) {
            AlineaAmountDisplay("$0", isPlaceholder: true, showCaret: true)
            AlineaAmountDisplay("$2,000", isPlaceholder: false)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: .spacingLarge) {
            AlineaAmountDisplay("$0", isPlaceholder: true, showCaret: true)
            AlineaAmountDisplay("$2,000", isPlaceholder: false)
        }
    }
    .preferredColorScheme(.light)
}
