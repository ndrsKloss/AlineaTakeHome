#if DEBUG
/// Test/preview double for `HapticFeedback`: records how many times feedback was
/// requested and plays nothing, keeping previews and unit tests isolated from the
/// Taptic Engine.
final class MockHapticFeedback: HapticFeedback {
    private(set) var keyPressedCount = 0

    func keyPressed() {
        keyPressedCount += 1
    }
}
#endif
