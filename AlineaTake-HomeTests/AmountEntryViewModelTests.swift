import Foundation
import Testing
@testable import AlineaTake_Home

/// Behaviour of `AmountEntryViewModel`'s keypad intents — specifically that every
/// keypad key fires haptic feedback (design-spec §3 comment 4), verified via an
/// injected `HapticFeedback` spy, while non-keypad actions do not.
@MainActor
@Suite struct AmountEntryViewModelTests {

    private func makeViewModel() -> (AmountEntryViewModel, MockHapticFeedback) {
        let haptics = MockHapticFeedback()
        let viewModel = AmountEntryViewModel(
            coordinator: MockAmountEntryCoordinator(),
            haptics: haptics
        )
        return (viewModel, haptics)
    }

    @Test func everyKeypadKeyFiresOneHaptic() {
        let (viewModel, haptics) = makeViewModel()
        viewModel.didTapDigit(5)
        viewModel.didTapDecimal()
        viewModel.didTapDelete()
        #expect(haptics.keyPressedCount == 3)
    }

    @Test func deleteOnEmptyStillFiresHaptic() {
        // A press is a press — feedback fires even when there is nothing to delete.
        let (viewModel, haptics) = makeViewModel()
        viewModel.didTapDelete()
        #expect(haptics.keyPressedCount == 1)
    }

    @Test func selectingASuggestionDoesNotFireHaptic() {
        // Suggestion chips are not keypad keys — the haptic requirement is
        // scoped to the keypad.
        let (viewModel, haptics) = makeViewModel()
        viewModel.didSelectSuggestion(2000)
        #expect(haptics.keyPressedCount == 0)
    }

    // MARK: deleteClearsAmount — drives the screen's snap-to-empty on the
    // clearing delete (the fade to "$|0" is skipped only for that step).

    @Test func deleteClearsAmountForASingleDigit() {
        // One integer digit → the next delete empties the field.
        let (viewModel, _) = makeViewModel()
        viewModel.didTapDigit(5)
        #expect(viewModel.deleteClearsAmount)
    }

    @Test func deleteDoesNotClearAmountWithDigitsRemaining() {
        // Two digits → the next delete leaves "5", so it does not clear.
        let (viewModel, _) = makeViewModel()
        viewModel.didTapDigit(5)
        viewModel.didTapDigit(5)
        #expect(!viewModel.deleteClearsAmount)
    }

    @Test func deleteDoesNotClearAmountWhenAlreadyEmpty() {
        // Nothing entered → a delete is a no-op, not a clearing delete.
        let (viewModel, _) = makeViewModel()
        #expect(!viewModel.deleteClearsAmount)
    }

    @Test func deleteDoesNotClearAmountAtABareSeparator() {
        // "5." → deleting removes the separator back to "5", not to empty.
        let (viewModel, _) = makeViewModel()
        viewModel.didTapDigit(5)
        viewModel.didTapDecimal()
        #expect(!viewModel.deleteClearsAmount)
    }
}
