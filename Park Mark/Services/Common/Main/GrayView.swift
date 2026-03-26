import SwiftUI
import WebKit
import SwiftData

struct GrayView: View {
    @StateObject private var deps = AppDependencyContainer()

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    @State var isLoading: Bool = true

    var body: some View {
        ZStack {
            if(isLoading){
                Loading(isLoading: $isLoading)
            } else {
                ContentView()
                    .environmentObject(deps)
                    .environmentObject(deps.settingsStore)
                    .environmentObject(deps.onboardingStore)
            }
        }
    }
}





