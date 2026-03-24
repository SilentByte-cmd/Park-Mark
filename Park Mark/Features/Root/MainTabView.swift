import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }

            NavigationStack {
                FindCarView()
            }
            .tabItem {
                Label("Find Car", systemImage: "location.fill")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
    }
}
