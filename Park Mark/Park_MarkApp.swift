import SwiftUI
import UIKit

@main
struct Park_MarkApp: App {
    @StateObject private var deps = AppDependencyContainer()

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deps)
                .environmentObject(deps.settingsStore)
                .environmentObject(deps.onboardingStore)
        }
    }
}
