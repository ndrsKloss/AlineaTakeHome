import Foundation
import Testing
@testable import AlineaTake_Home

/// Behaviour of the calculator-style `AmountEntry` model: how keystrokes build,
/// cap, and delete the entered value. Expected values are independent literals
/// (worked examples), not recomputed from the implementation.
@MainActor
@Suite struct AmountEntryTests {

    // MARK: Empty / placeholder

    @Test func newEntryIsEmpty() {
        let entry = AmountEntry()
        #expect(entry.isEmpty)
        #expect(entry.decimalValue == 0)
    }

    // MARK: Building the integer part

    @Test func digitsBuildTheIntegerValue() {
        let entry = typing([2, 0, 0, 0])
        #expect(!entry.isEmpty)
        #expect(entry.decimalValue == 2000)
    }

    @Test func firstNonZeroDigitReplacesALoneZero() {
        // "0" then "5" reads as 5, not 05.
        #expect(typing([0, 5]).decimalValue == 5)
    }

    @Test func repeatedZeroStaysZero() {
        let entry = typing([0, 0])
        #expect(entry.decimalValue == 0)
        #expect(!entry.isEmpty) // a typed 0 is no longer the placeholder
    }

    @Test func integerLengthIsCappedAtTwelveDigits() {
        // 13 ones offered; only 12 are kept.
        let entry = typing(Array(repeating: 1, count: 13))
        #expect(entry.decimalValue == Decimal(string: "111111111111")!)
    }

    // MARK: Decimal / fraction

    @Test func decimalSeparatorStartsTheFraction() {
        let entry = AmountEntry().appendingDecimalSeparator()
        #expect(entry.hasDecimalSeparator)
        #expect(!entry.isEmpty)
    }

    @Test func decimalOnEmptySeedsAZeroInteger() {
        let entry = AmountEntry().appendingDecimalSeparator()
        #expect(entry.decimalValue == 0)
    }

    @Test func fractionIsCappedAtTwoDigits() {
        let entry = typing([2, 5]).appendingDecimalSeparator().appending(digit: 9).appending(digit: 9).appending(digit: 9)
        // Third fraction digit ignored → 25.99, not 25.999.
        #expect(entry.decimalValue == Decimal(string: "25.99")!)
    }

    @Test func secondSeparatorIsIgnored() {
        let once = AmountEntry().appending(digit: 5).appendingDecimalSeparator()
        let twice = once.appendingDecimalSeparator()
        #expect(once == twice)
    }

    // MARK: Delete

    @Test func deleteRemovesFractionThenSeparatorThenInteger() {
        var entry = typing([5]).appendingDecimalSeparator().appending(digit: 2) // 5.2
        entry = entry.deletingLast() // 5.
        #expect(entry.hasDecimalSeparator)
        #expect(entry.decimalValue == 5)
        entry = entry.deletingLast() // 5
        #expect(!entry.hasDecimalSeparator)
        #expect(entry.decimalValue == 5)
        entry = entry.deletingLast() // empty
        #expect(entry.isEmpty)
    }

    @Test func deletingTheSeededDecimalReturnsToPlaceholder() {
        // "." on empty seeds "0."; deleting it must not leave a stray "0".
        let entry = AmountEntry().appendingDecimalSeparator().deletingLast()
        #expect(entry.isEmpty)
    }

    // MARK: Seeding from a suggestion

    @Test func wholeAmountSeedsTheIntegerValue() {
        let entry = AmountEntry(wholeAmount: 2000)
        #expect(entry.decimalValue == 2000)
        #expect(!entry.hasDecimalSeparator)
    }

    // MARK: Helpers

    private func typing(_ digits: [Int]) -> AmountEntry {
        digits.reduce(into: AmountEntry()) { $0 = $0.appending(digit: $1) }
    }
}
