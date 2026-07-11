import CoreFoundation

/// Spacing and layout tokens, captured from the Figma amount screen
/// (design-spec §5/§6/§8). Semantic names; layout code uses these rather than
/// inline constants.
extension CGFloat {

    // MARK: Generic scale

    /// 8
    static let spacingXSmall: CGFloat = 8
    /// 12 — gap between suggestion chips.
    static let spacingSmall: CGFloat = 12
    /// 16
    static let spacingMedium: CGFloat = 16
    /// 24
    static let spacingLarge: CGFloat = 24

    // MARK: Screen-specific (Figma-confirmed)

    /// 20 — default horizontal screen margin for centre-column content.
    static let defaultMargins: CGFloat = 20
    /// 12 — horizontal gap between suggestion chips.
    static let chipGap: CGFloat = 12
    /// 24 — side margin of the Review button ((393 − 345) / 2).
    static let screenMarginButton: CGFloat = 24
    /// 40 — side margin of the suggestion-bubble row.
    static let screenMarginChips: CGFloat = 40
    /// 46 — keypad side margin.
    static let keypadSideMargin: CGFloat = 46
    /// 68 — vertical pitch between keypad rows.
    static let keypadRowPitch: CGFloat = 68
    /// 130 — horizontal pitch between keypad columns.
    static let keypadColumnPitch: CGFloat = 130
}
