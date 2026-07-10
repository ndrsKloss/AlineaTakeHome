import SwiftUI

/// Owns the app's navigation stack and is the single source of truth for the
/// `NavigationPath`. Concrete implementation of `AppRouting`, injected into
/// feature coordinators by the composition root (`RootView`).
@Observable
final class AppCoordinator: AppRouting {
    var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
