import Foundation

struct AppSettings: Codable, Equatable {
    var accentTheme: AppAccentTheme
    var defaultParkingType: ParkingType
    var defaultReminderEnabled: Bool
    var defaultReminderOffsetMinutes: Int

    static let `default` = AppSettings(
        accentTheme: .emerald,
        defaultParkingType: .garage,
        defaultReminderEnabled: false,
        defaultReminderOffsetMinutes: 120
    )
}
