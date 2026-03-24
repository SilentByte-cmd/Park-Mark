import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    func formattedReminderOffset(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours == 0 {
            return "\(minutes) minutes"
        }
        if mins == 0 {
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
        return "\(hours) h \(mins) m"
    }
}
