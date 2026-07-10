import Foundation

/// Navigable destinations, resolved to views by the composition root via
/// `.navigationDestination(for:)`.
///
/// The Amount entry screen is the root, and its back / Review actions are
/// currently no-ops (see `design-specification.md` §10), so there are no
/// destinations yet. New cases are added here as real flows are introduced;
/// nothing else about the navigation wiring needs to change.
enum AppRoute: Hashable {
    // No destinations yet.
}
