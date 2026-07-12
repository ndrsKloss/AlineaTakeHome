import SwiftUI

/// The numeric keypad: a 3×4 grid of digit keys (`1`–`9`, `0`), a decimal-separator
/// key, and a delete key (design-spec §9 "KeypadKey", Figma `Keyboard`).
///
/// Presentation + event reporting only. The amount value, edit logic and haptics
/// are owned by the view model; the decimal key's real enable/disable rule is an
/// open product question (design-spec §12) supplied here via `isDecimalEnabled`.
struct AlineaKeyboard: View {
    /// Label for the decimal key. The locale-aware separator is passed in by the
    /// view model later (`NFR-LOC`); defaults to `"."` to match the design.
    var decimalSeparator: String
    /// Whether the decimal key accepts taps. The business rule lives in the view
    /// model (design-spec §12 Q1); the component only reflects it.
    var isDecimalEnabled: Bool
    let onDigit: (Int) -> Void
    let onDecimal: () -> Void
    let onDelete: () -> Void

    init(
        decimalSeparator: String = ".",
        isDecimalEnabled: Bool = true,
        onDigit: @escaping (Int) -> Void,
        onDecimal: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.decimalSeparator = decimalSeparator
        self.isDecimalEnabled = isDecimalEnabled
        self.onDigit = onDigit
        self.onDecimal = onDecimal
        self.onDelete = onDelete
    }

    private enum Key {
        case digit(Int)
        case decimal
        case delete
    }

    private let layout: [[Key]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.decimal, .digit(0), .delete],
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(layout.indices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(layout[row].indices, id: \.self) { column in
                        keyView(layout[row][column])
                    }
                }
                .frame(height: Layout.rowHeight)
            }
        }
        // The row pitch is a fixed Figma 68pt (design-spec §9). The digits scale
        // with Dynamic Type, so cap the keypad's range at the largest size whose
        // glyph still fits the 68pt row — beyond it the digits would clip
        // (`NFR-A11Y-004`). Touch targets stay ≥44pt via `AlineaNumber`'s
        // `minHeight`, independent of this cap (`NFR-A11Y-006`).
        .dynamicTypeSize(...Layout.maxDynamicTypeSize)
    }

    @ViewBuilder
    private func keyView(_ key: Key) -> some View {
        switch key {
        case .digit(let value):
            AlineaNumber("\(value)") { onDigit(value) }
        case .decimal:
            AlineaNumber(decimalSeparator, isEnabled: isDecimalEnabled) { onDecimal() }
        case .delete:
            deleteKey
        }
    }

    private var deleteKey: some View {
        Button(action: onDelete) {
            Image(Icons.delete)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.deleteWidth, height: Layout.deleteHeight)
                .foregroundStyle(Color.textPrimary) // template asset; hue adapts, baked alpha keeps it subtle
                .frame(maxWidth: .infinity, minHeight: 44) // fills column; ≥44pt target (NFR-A11Y-006)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Strings.delete)
        .accessibilityAddTraits(.isKeyboardKey)
    }
}

private enum Layout {
    /// Figma keyboard row pitch (design-spec §9 / node 2007:141), sourced from
    /// the shared `keypadRowPitch` token so the value has a single home.
    static let rowHeight: CGFloat = .keypadRowPitch
    /// Largest Dynamic Type size the keypad honors before a scaled digit clips
    /// the fixed `rowHeight` (empirically verified). Standard sizes and the
    /// lower accessibility sizes still scale (`NFR-A11Y-001/002`).
    static let maxDynamicTypeSize: DynamicTypeSize = .accessibility1
    /// Backspace glyph size (design-spec §3.4, ~51.095 × 46.593).
    static let deleteWidth: CGFloat = 51
    static let deleteHeight: CGFloat = 47
}

/// User-facing copy for the keypad. Separate from `Layout` (geometry). The
/// backspace key's VoiceOver label is a localizable resource (`NFR-LOC-002/009`),
/// resolved at runtime via `Localizable.xcstrings`; `String(localized:)` keeps
/// the translator `comment` with the literal for string extraction.
private enum Strings {
    static let delete = String(
        localized: "Delete",
        comment: "Backspace key on the amount keypad"
    )
}

/// Asset names used by the keypad. Separate from `Layout` (geometry) and
/// `Strings` (copy).
private enum Icons {
    static let delete = "ic_delete_numpad"
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        AlineaKeyboard(
            onDigit: { _ in },
            onDecimal: {},
            onDelete: {}
        )
        .padding(.horizontal, .screenMarginButton)
    }
    .preferredColorScheme(.dark)
}
