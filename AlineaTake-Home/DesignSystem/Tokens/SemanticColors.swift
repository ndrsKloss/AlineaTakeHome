import SwiftUI
import UIKit

extension Color {
    /// Builds an appearance-adaptive color that resolves to `light` in Light Mode
    /// and `dark` in Dark Mode.
    ///
    /// Semantic roles are adaptive from day one so views bind to a single token
    /// regardless of appearance (`NFR-THEME-003/004`).
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

/// Semantic color roles — the vocabulary feature code and components use.
///
/// **Dark** values are confirmed from the Figma design (Dark-only reference).
/// **Light** values resolve `FAD-THEME-a`: there is no Figma Light design, so they
/// are **derived** as a faithful re-theme that preserves the same hierarchy,
/// emphasis, and semantic intent (`NFR-THEME-005`) at WCAG AA contrast
/// (`NFR-THEME-006`). The per-role assumption is noted inline.
///
/// Disabled / error roles are intentionally **not defined** — the design provides
/// no values and they must not be invented (design-spec §12).
extension Color {

    /// Screen background. Dark #18161F; Light #F4F3F8 (soft cool off-white).
    static let backgroundPrimary = Color(
        light: .cloud,
        dark: .ink
    )

    /// Primary text / icons. Dark #FFFFFF; Light #18161F (near-black, ~15:1 on bg).
    static let textPrimary = Color(
        light: .ink,
        dark: .paletteWhite
    )

    /// Faint amount placeholder (`$0`). Dark: white ~4%. Light: ink @20% — light
    /// backgrounds need more than 4% to read as a comparably faint, de-emphasized ghost.
    static let textPlaceholder = Color(
        light: Color.ink.opacity(0.20),
        dark: Color.paletteWhite.opacity(0.04)
    )

    /// Suggestion-chip surface. Dark #23212C @75%; Light: ink @8% (subtle elevated
    /// grey pill; keeps the dark label legible).
    static let surfaceChip = Color(
        light: Color.ink.opacity(0.08),
        dark: Color.chipInk.opacity(0.75)
    )

    /// Brand gradient start (e.g. Review border). #B24DCC in both — brand identity
    /// is appearance-independent and the mid-saturated magenta reads on either bg.
    static let brandGradientStart = Color(
        light: .brandMagenta,
        dark: .brandMagenta
    )

    /// Brand gradient end. #8955F9 in both (see `brandGradientStart`).
    static let brandGradientEnd = Color(
        light: .brandPurple,
        dark: .brandPurple
    )

    /// Label on the primary button surface. Dark #22212D (on the white pill);
    /// Light #FFFFFF (on the inverted dark pill — see `primaryButtonSurface`).
    static let onBrand = Color(
        light: .paletteWhite,
        dark: .onBrandInk
    )

    /// Primary button (Review) surface. Dark #FFFFFF (white pill pops on dark);
    /// Light #18161F — the pill inverts to dark so it stays dominant on a light bg
    /// (`NFR-THEME-005`). Consumed by `AlineaSpecialButton`.
    static let primaryButtonSurface = Color(
        light: .ink,
        dark: .paletteWhite
    )

    /// Hairline rim shadow on the special-button pill. #A467E1 in both — assumed
    /// appearance-independent like the rest of the brand halo (Figma 2010:497 is
    /// Dark-only reference; no Light value is drawn).
    static let primaryButtonRim = Color(
        light: .rimLilac,
        dark: .rimLilac
    )
}

extension Gradient {
    /// The special-button halo gradient (Figma `ButtonBg` 2010:587): a brand
    /// sweep white → accent yellow → magenta → purple → blue → white. Brand
    /// identity, so identical in both appearances.
    static let halo = Gradient(stops: [
        .init(color: .paletteWhite, location: 0.0099),
        .init(color: .accentYellow, location: 0.2820),
        .init(color: .brandMagenta, location: 0.3656),
        .init(color: .brandPurple, location: 0.4492),
        .init(color: .brandBlue, location: 0.5285),
        .init(color: .paletteWhite, location: 0.9223),
    ])
}
