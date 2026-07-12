import SwiftUI
import UIKit
import Testing
@testable import AlineaTake_Home

/// Verifies the semantic color roles resolve to the **ratified palette**
/// (`FAD-THEME-a`) in each appearance and preserve the intended hierarchy
/// (`NFR-THEME-003/004/005`). `Color(light:dark:)` wraps a dynamic `UIColor`, so
/// each role can be resolved under a `UITraitCollection` and compared, component
/// by component, against the expected primitive.
@MainActor
@Suite struct SemanticColorsTests {

    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    // MARK: Each role maps to the expected primitive in each appearance

    @Test func backgroundPrimaryResolvesPerAppearance() {
        expectSameColor(Color.backgroundPrimary, in: light, equals: .cloud)
        expectSameColor(Color.backgroundPrimary, in: dark, equals: .ink)
    }

    @Test func textPrimaryResolvesPerAppearance() {
        expectSameColor(Color.textPrimary, in: light, equals: .ink)
        expectSameColor(Color.textPrimary, in: dark, equals: .paletteWhite)
    }

    @Test func amountValueResolvesPerAppearance() {
        expectSameColor(Color.amountValue, in: light, equals: .ink)
        expectSameColor(Color.amountValue, in: dark, equals: .paletteWhite)
    }

    @Test func onBrandResolvesPerAppearance() {
        expectSameColor(Color.onBrand, in: light, equals: .paletteWhite)
        expectSameColor(Color.onBrand, in: dark, equals: .onBrandInk)
    }

    @Test func primaryButtonSurfaceInvertsPerAppearance() {
        expectSameColor(Color.primaryButtonSurface, in: light, equals: .ink)
        expectSameColor(Color.primaryButtonSurface, in: dark, equals: .paletteWhite)
    }

    @Test func placeholderCarriesTheExpectedAlphaPerAppearance() {
        // Dark: white @4%; Light: ink @20% (design-spec §2.10).
        expectSameColor(Color.textPlaceholder, in: light, equals: Color.ink.opacity(0.20))
        expectSameColor(Color.textPlaceholder, in: dark, equals: Color.paletteWhite.opacity(0.04))
    }

    @Test func chipSurfaceCarriesTheExpectedAlphaPerAppearance() {
        expectSameColor(Color.surfaceChip, in: light, equals: Color.ink.opacity(0.08))
        expectSameColor(Color.surfaceChip, in: dark, equals: Color.chipInk.opacity(0.75))
    }

    // MARK: Invariants — hierarchy is preserved (NFR-THEME-005)

    @Test func brandGradientIsAppearanceIndependent() {
        // Brand identity reads on either background — identical in both.
        for role in [Color.brandGradientStart, Color.brandGradientEnd, Color.primaryButtonRim] {
            #expect(rgba(role, light) == rgba(role, dark))
        }
    }

    @Test func backgroundAndTextDifferBetweenAppearances() {
        #expect(rgba(Color.backgroundPrimary, light) != rgba(Color.backgroundPrimary, dark))
        #expect(rgba(Color.textPrimary, light) != rgba(Color.textPrimary, dark))
    }

    @Test func textInvertsAgainstBackgroundInEachAppearance() {
        // Text must contrast its background: dark-mode text == light-mode bg family
        // is not required, but text and bg must never coincide within an appearance.
        #expect(rgba(Color.textPrimary, light) != rgba(Color.backgroundPrimary, light))
        #expect(rgba(Color.textPrimary, dark) != rgba(Color.backgroundPrimary, dark))
    }

    // MARK: Helpers

    private typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)

    private func rgba(_ color: Color, _ traits: UITraitCollection) -> RGBA {
        let resolved = UIColor(color).resolvedColor(with: traits)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    private func expectSameColor(
        _ role: Color,
        in traits: UITraitCollection,
        equals expected: Color,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let a = rgba(role, traits)
        let b = rgba(expected, traits)
        let tol: CGFloat = 0.01
        #expect(abs(a.r - b.r) < tol && abs(a.g - b.g) < tol && abs(a.b - b.b) < tol && abs(a.a - b.a) < tol,
                "expected \(b) but resolved \(a)", sourceLocation: sourceLocation)
    }
}
