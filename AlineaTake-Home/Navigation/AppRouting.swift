import Foundation

/// Abstraction over the app's navigation stack.
///
/// Feature coordinators depend on this protocol rather than a concrete
/// coordinator, so they can be exercised with a test/preview double and
/// remain decoupled from `NavigationPath`.
protocol AppRouting: AnyObject {
    func push(_ route: AppRoute)
    func pop()
    func popToRoot()
}
