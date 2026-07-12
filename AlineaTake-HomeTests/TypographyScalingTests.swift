import SwiftUI
import UIKit
import Testing
@testable import AlineaTake_Home

/// Guards the keypad's Dynamic Type behavior (`NFR-A11Y-001/002`): the digit
/// token is a *scaling* descriptor (regression guard for the earlier
/// "keypad pinned at a fixed size" bug), and the keypad caps Dynamic Type at the
/// documented size that preserves the fixed 68pt Figma row pitch (design-spec §9).
@MainActor
@Suite struct TypographyScalingTests {

    // MARK: The keypad-digit token contract

    @Test func keypadDigitTokenMatchesTheDesign() {
        let token = AlineaScalableSystemStyle.keypadDigit
        #expect(token.size == 36)
        #expect(token.weight == .medium)
        #expect(token.relativeTo == .title) // SwiftUI's name for UIFont's .title1
        #expect(token.tracking == 0)
        #expect(token.lineSpacing == 0)
    }

    // MARK: The token actually scales with Dynamic Type

    @Test func keypadDigitGrowsMonotonicallyWithContentSize() {
        // `.title` (Font.TextStyle) is the `.title1` UIKit curve the token scales
        // along; UIFontMetrics is exactly what the `@ScaledMetric` in the token's
        // modifier uses under the hood.
        let metrics = UIFontMetrics(forTextStyle: .title1)
        func scaled(_ category: UIContentSizeCategory) -> CGFloat {
            metrics.scaledValue(
                for: AlineaScalableSystemStyle.keypadDigit.size,
                compatibleWith: UITraitCollection(preferredContentSizeCategory: category)
            )
        }

        let base = scaled(.large)               // default size
        let big = scaled(.extraExtraExtraLarge) // largest standard size
        let ax = scaled(.accessibilityExtraLarge)

        #expect(base == 36) // unscaled at the default category
        #expect(big > base)
        #expect(ax > big)   // keeps growing into the accessibility range
    }

    // MARK: The keypad caps Dynamic Type to protect the fixed row pitch

    @Test func keypadCapsDynamicTypeWithinTheAccessibilityRange() {
        let cap = AlineaKeyboard.maxDynamicTypeSize
        #expect(cap == .accessibility1)
        // Still scales past the standard range, but not to the largest AX sizes
        // (which would clip the 68pt row).
        #expect(cap > .large)
        #expect(cap < .accessibility5)
    }
}
