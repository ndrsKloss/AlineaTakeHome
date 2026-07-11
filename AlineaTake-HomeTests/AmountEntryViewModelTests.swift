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
}
