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

    /// - Parameters:
    ///   - text: The pre-formatted amount (e.g. `"$0"`, `"$2,000"`). Verbatim —
    ///     grouping/locale is the caller's job (`NFR-LOC`), like `AlineaChip`.
    ///   - isPlaceholder: Faint placeholder treatment (empty state) vs the bright
    ///     value fill (filled state).
    ///   - showCaret: Whether the blinking end-caret trails the value
    ///     (design-spec §10.5; filled-state caret is caller's call — §12 Q3).
    init(
        _ text: String,
        isPlaceholder: Bool,
        showCaret: Bool = false
    ) {
        self.text = text
        self.isPlaceholder = isPlaceholder
        self.showCaret = showCaret
    }

    var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: text))
    }

    @ViewBuilder
    private var content: some View {
        if showCaret, isPlaceholder, let split = text.firstIndex(where: \.isNumber) {
            // Empty state renders "$|0": the caret marks the insertion point,
            // between the currency symbol and the placeholder zero. The design
            // pins the caret at the frame's horizontal centre (design-spec §3.1:
            // caret at x≈197 ≈ 393/2), *not* the amount block — for a wide symbol
            // like BRL's "R$" a centred block would still push the caret off to
            // the right. Two equal `maxWidth: .infinity` halves share the space
            // around the fixed-width caret, so the caret stays dead-centre for
            // any symbol width: `lead` (symbol) hugs it from the left, `value`
            // (digit + any trailing symbol) from the right.
            //
            // Whitespace is trimmed at the split so the caret gets a symmetric
            // `midCaretGap` on both sides regardless of the currency's own
            // symbol↔number separator (`.whitespaces` includes the no-break
            // space). Interior separators — e.g. the `\u{00A0}` between `0` and
            // `€` in es-ES `0\u{00A0}€` — are preserved as they are not
            // surrounding whitespace; a suffix currency leaves `lead` empty,
            // whose flexible half still keeps the caret centred.
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
        // A hidden twin drives layout with the width animation suppressed, so
        // the frame snaps to the final width immediately; the visible text in
        // its overlay is then always proposed that final size, and the value
        // crossfade plays inside an already-final frame. Without this, the
        // frame interpolates old→new width while the incoming string lays out
        // at full size, and the glyph nearest the moving edge (the leading
        // `$`) is clipped mid-animation. The `.transaction` scope ends before
        // `.overlay`, so the visible text keeps the animated transaction from
        // the screen's `withAnimation` (value + branch crossfades).
        //
        // The snap is directional: clipping only happens while the frame
        // *grows* (mid-animation frame narrower than the final-size content).
        // When the edit can only shorten the text (delete — flagged by the
        // screen via `Transaction.amountMayShrink`), the mid-animation frame
        // is always at least as wide as the final content, so the width is
        // left animated: the value glides narrower with the caret instead of
        // snapping in one frame.
        glyphText(string)
            .hidden()
            .transaction { txn in
                if !txn.amountMayShrink {
                    txn.animation = nil
                }
            }
            .overlay(
                glyphText(string)
                    .foregroundStyle(valueFill)
                    // Blur-crossfade the whole value on edits: `.id` swaps the
                    // view identity per string, so the outgoing value blurs +
                    // fades out while the incoming one blurs in. The animation
                    // transaction is owned by `AmountEntryView`.
                    .transition(Self.valueSwap)
                    .id(string)
            )
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

    /// The shared text configuration for the layout twin and the visible copy —
    /// both must agree on size so the §10.7 long-amount shrink still applies.
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

/// Marks a transaction as an amount edit that can only *shorten* the text
/// (delete). `AlineaAmountDisplay` reads it to decide whether the value frame
/// may animate its width: shrinking never clips (the frame stays at least as
/// wide as the final content mid-animation), so the deleted digit gets to roll
/// out; the default `false` keeps the snap-to-final-width behavior that
/// protects growing edits from edge clipping.
enum AmountShrinkTransactionKey: TransactionKey {
    static let defaultValue = false
}

extension Transaction {
    /// Whether the current amount edit can only shorten the displayed text.
    /// Set by the screen (`AmountEntryView`) on delete; read by
    /// `AlineaAmountDisplay`'s hidden layout twin.
    var amountMayShrink: Bool {
        get { self[AmountShrinkTransactionKey.self] }
        set { self[AmountShrinkTransactionKey.self] = newValue }
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
