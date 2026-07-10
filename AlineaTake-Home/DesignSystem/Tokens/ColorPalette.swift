import SwiftUI

extension Color {
    /// Hex initializer for defining palette primitives.
    /// Accepts `RRGGBB` or `RRGGBBAA`.
    init(hex: String) {
        let raw = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: raw).scanHexInt64(&value)

        let r, g, b, a: Double
        switch raw.count {
        case 8: // RRGGBBAA
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        default: // RRGGBB
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/// Palette primitives — the raw brand/neutral values captured from Figma.
///
/// Primitives are the private vocabulary of the design system. Feature code and
/// components consume **semantic** roles (see `SemanticColors.swift`), never
/// these primitives directly.
extension Color {

    // MARK: Brand

    /// #B24DCC — Figma `main/brand`. Review gradient start; badge border.
    static let brandMagenta = Color(hex: "B24DCC")
    /// #8955F9 — Figma `strategies/st01`. Review gradient end.
    static let brandPurple = Color(hex: "8955F9")
    /// #2073DF — Figma `strategies/st03`. Part of the brand gradient palette.
    static let brandBlue = Color(hex: "2073DF")
    /// #FFEE59 — Figma `main/accent`. Defined in the system; unused on the amount screen.
    static let accentYellow = Color(hex: "FFEE59")

    // MARK: Neutrals

    /// #FFFFFF — Figma `main/white` / `dark foreground`.
    static let paletteWhite = Color(hex: "FFFFFF")
    /// #18161F — screen background base.
    static let ink = Color(hex: "18161F")
    /// #23212C — suggestion-chip surface base (used at 75% opacity).
    static let chipInk = Color(hex: "23212C")
    /// #22212D — dark label on the white Review pill.
    static let onBrandInk = Color(hex: "22212D")
}
