import Combine
import Foundation
import UserNotifications

@MainActor
final class ParkingNotificationService: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    init() {
        Task { await refreshAuthorizationStatus() }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    func scheduleReminder(for spot: ParkingSpot) {
        guard let fireDate = spot.reminderEndTime else { return }
        let remaining = fireDate.timeIntervalSinceNow
        guard remaining > 5 else { return }

        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: spot.id)])

        let content = UNMutableNotificationContent()
        content.title = "Parking reminder"
        content.body = "Check your session for \(spot.title)."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: spot.id),
            content: content,
            trigger: trigger
        )

        center.add(request, withCompletionHandler: nil)
    }

    func cancelReminder(for spotId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: spotId)])
        center.removeDeliveredNotifications(withIdentifiers: [notificationIdentifier(for: spotId)])
    }

    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    private func notificationIdentifier(for spotId: UUID) -> String {
        "park_pin_reminder_\(spotId.uuidString)"
    }
}
