import CoreFoundation

/// Corner-radius tokens, captured from the Figma amount screen (design-spec §5).
extension CGFloat {

    /// 16 — screen frame.
    static let radiusFrame: CGFloat = 16
    /// 26 — circular control (back button, ~25.988).
    static let radiusControl: CGFloat = 26
    /// 30 — Review pill inner surface (~29.869).
    static let radiusButtonInner: CGFloat = 30
    /// 999 — fully rounded pill (chips, button outer).
    static let radiusPill: CGFloat = 999
    /// 100 — small rounded elements (caret, home indicator bar).
    static let radiusRound: CGFloat = 100
}
