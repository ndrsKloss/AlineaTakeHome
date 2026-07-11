import SwiftUI

/// The amount display (arch-spec §10 `AmountDisplay`; Figma `2010:549` empty /
/// `2010:550` filled): the large centered value at the top of the Amount screen.
/// Borderless free-standing text (design-spec §3) — no field chrome.
///
/// Presentation only. The caller passes an already-formatted amount string and
/// tells the display whether it's the faint placeholder and whether to show the
/// trailing caret; the amount value, locale formatting, and caret/placeholder
/// rules are owned by the view model (design-spec §10.5, §12).
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
        HStack(spacing: Layout.caretGap) {
            value
            if showCaret {
                AmountCaret()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: text))
    }

    private var value: some View {
        Text(verbatim: text)
            .textStyle(.display)
            .lineLimit(1)
            .minimumScaleFactor(Layout.minScale) // shrink long amounts (design-spec §10.7)
            .foregroundStyle(valueFill)
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

/// The blinking end-caret: a solid rounded bar trailing the amount (design-spec
/// §3.1 / §10.5, ~3 × ~100, radius 100). Owns its blink; steady under Reduce
/// Motion (`NFR-A11Y`). Decorative — hidden from VoiceOver (the parent reads the
/// value).
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
