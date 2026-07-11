import UIKit

/// A haptic-feedback capability exposed behind a protocol so feature code depends
/// on the abstraction rather than a concrete generator (architecture-spec §3
/// "Services" — a single external capability, swappable and testable). Used for
/// keypad key presses: design-spec §3 comment 4 requires every keypad key to
/// fire haptic feedback on press.
protocol HapticFeedback {
    /// Plays the feedback for a single keypad key press.
    func keyPressed()
}

/// `UIImpactFeedbackGenerator`-backed implementation. A light impact reads as a
/// subtle key click; the design spec asks only for "haptic feedback" (no
/// intensity), so `.light` is the chosen default. `UIFeedbackGenerator` honours
/// the system Sounds & Haptics setting automatically, so no manual gating is
/// needed (haptics are not motion, so Reduce Motion does not apply).
///
/// The type is main-actor isolated by the project's default actor isolation,
/// matching `UIImpactFeedbackGenerator`'s own isolation.
final class SystemHapticFeedback: HapticFeedback {
    private let generator = UIImpactFeedbackGenerator(style: .light)

    init() {
        generator.prepare()
    }

    func keyPressed() {
        generator.impactOccurred()
        // Keep the Taptic Engine warm so the next press stays low-latency.
        generator.prepare()
    }
}
