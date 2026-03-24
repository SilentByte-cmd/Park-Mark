import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var deps: AppDependencyContainer
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var onboardingStore: OnboardingStore

    var body: some View {
        Group {
            if onboardingStore.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(deps.parkingStore)
                    .environmentObject(deps.settingsStore)
                    .environmentObject(deps.notificationService)
                    .environmentObject(onboardingStore)
            } else {
                OnboardingView()
                    .environmentObject(onboardingStore)
                    .environmentObject(deps.settingsStore)
            }
        }
        .environmentObject(deps.locationManager)
        .environmentObject(deps.geocodingService)
        .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
        .onAppear {
            deps.parkingStore.rescheduleAllActiveReminders()
            deps.locationManager.refreshAuthorizationStatus()
            Task {
                await deps.notificationService.refreshAuthorizationStatus()
            }
        }
    }
}
