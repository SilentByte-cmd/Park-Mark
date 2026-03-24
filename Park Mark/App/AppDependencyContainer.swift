import Combine
import SwiftUI

@MainActor
final class AppDependencyContainer: ObservableObject {
    let notificationService: ParkingNotificationService
    let parkingStore: ParkingSpotStore
    let settingsStore: AppSettingsStore
    let onboardingStore: OnboardingStore
    let locationManager: ParkPinLocationManager
    let geocodingService: GeocodingService

    init() {
        let notificationService = ParkingNotificationService()
        self.notificationService = notificationService
        self.parkingStore = ParkingSpotStore(notificationService: notificationService)
        self.settingsStore = AppSettingsStore()
        self.onboardingStore = OnboardingStore()
        self.locationManager = ParkPinLocationManager()
        self.geocodingService = GeocodingService()
    }
}
