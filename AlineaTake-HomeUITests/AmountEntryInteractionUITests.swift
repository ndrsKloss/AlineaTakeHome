import XCTest

/// Drives the amount keypad end-to-end through the real UI — typing digits,
/// deleting, entering a decimal, and selecting suggestion chips — asserting the
/// amount and the empty⇄filled state respond (design-spec §10, `NFR-LOC-011`).
/// Runs in the default (en) locale so the digit / "Delete" / "." / "Review"
/// labels are stable; amount value is read from the `amountDisplay` spoken label
/// (a stable number substring), and screen state from chip / Review presence.
final class AmountEntryInteractionUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    // MARK: Scenarios

    @MainActor
    func testStartsEmptyWithChipsAndNoReview() {
        XCTAssertTrue(chip(500).waitForExistence(timeout: 5))
        XCTAssertTrue(chip(2000).exists)
        XCTAssertTrue(chip(10000).exists)
        XCTAssertFalse(reviewButton.exists, "Review should be hidden while empty")
        XCTAssertTrue(amountLabel.contains("0"), "empty amount should read a zero, got '\(amountLabel)'")
    }

    @MainActor
    func testTypingDigitsBuildsAmountAndSwapsToReview() {
        tapDigits("123")

        XCTAssertTrue(waitForAmount(toContain: "123"))
        // State A → B: Review appears, chips are gone (design-spec §10).
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 2))
        XCTAssertFalse(chip(500).exists, "chips should be hidden once a value is entered")
    }

    @MainActor
    func testDeleteRemovesLastDigitAndReturnsToPlaceholder() {
        tapDigits("123")
        XCTAssertTrue(waitForAmount(toContain: "123"))

        key("Delete").tap()
        XCTAssertTrue(waitForAmount(toContain: "12"))

        // Delete the rest → back to the empty placeholder (chips return).
        key("Delete").tap()
        key("Delete").tap()
        XCTAssertTrue(chip(500).waitForExistence(timeout: 2), "chips should return when empty")
        XCTAssertFalse(reviewButton.exists)
    }

    @MainActor
    func testDecimalEntryAndDecimalKeyDisables() {
        tapDigits("5")
        key(".").tap()
        tapDigits("5")

        XCTAssertTrue(waitForAmount(toContain: "5.5"))
        // A second separator is not allowed once one is present (`NFR-LOC-011`).
        XCTAssertFalse(key(".").isEnabled, "decimal key should disable after a separator is entered")
    }

    @MainActor
    func testSelectingAChipSetsTheAmount() {
        chip(2000).tap()

        XCTAssertTrue(waitForAmount(toContain: "2,000"))
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 2))
        XCTAssertFalse(chip(2000).exists, "chips should be hidden after selection")
    }

    // MARK: Element accessors

    /// A keypad key surfaces as a `.key` (it carries `.isKeyboardKey`) or a
    /// `.button` depending on the runtime — return whichever exists.
    private func key(_ label: String) -> XCUIElement {
        let asKey = app.keys[label]
        return asKey.exists ? asKey : app.buttons[label]
    }

    private func chip(_ value: Int) -> XCUIElement { app.buttons["chip-\(value)"] }

    private var reviewButton: XCUIElement { app.buttons["Review"] }

    private var amountLabel: String {
        app.descendants(matching: .any).matching(identifier: "amountDisplay").firstMatch.label
    }

    // MARK: Helpers

    private func tapDigits(_ digits: String) {
        for d in digits { key(String(d)).tap() }
    }

    /// Polls the amount's spoken label for the expected number substring, since
    /// the value animates (blur-crossfade) after each edit.
    private func waitForAmount(toContain substring: String, timeout: TimeInterval = 3) -> Bool {
        let element = app.descendants(matching: .any).matching(identifier: "amountDisplay").firstMatch
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.label.contains(substring) { return true }
            usleep(100_000) // 0.1s
        }
        return false
    }
}
