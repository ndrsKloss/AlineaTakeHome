#if DEBUG
import Foundation

/// Test/preview double for `AmountEntryCoordinating`. Records nothing and
/// performs no navigation, keeping previews and unit tests isolated.
final class MockAmountEntryCoordinator: AmountEntryCoordinating {
    private(set) var goBackCallCount = 0
    private(set) var showReviewCallCount = 0

    func goBack() {
        goBackCallCount += 1
    }

    func showReview() {
        showReviewCallCount += 1
    }
}
#endif
