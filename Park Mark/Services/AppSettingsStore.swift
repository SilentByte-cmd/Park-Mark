import Combine
import Foundation
import SwiftUI

@MainActor
final class AppSettingsStore: ObservableObject {
    @Published private(set) var settings: AppSettings

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: DefaultsKeys.appSettings),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    func updateAccent(_ theme: AppAccentTheme) {
        settings = AppSettings(
            accentTheme: theme,
            defaultParkingType: settings.defaultParkingType,
            defaultReminderEnabled: settings.defaultReminderEnabled,
            defaultReminderOffsetMinutes: settings.defaultReminderOffsetMinutes
        )
        persist()
    }

    func updateDefaultParkingType(_ type: ParkingType) {
        settings = AppSettings(
            accentTheme: settings.accentTheme,
            defaultParkingType: type,
            defaultReminderEnabled: settings.defaultReminderEnabled,
            defaultReminderOffsetMinutes: settings.defaultReminderOffsetMinutes
        )
        persist()
    }

    func updateDefaultReminderEnabled(_ enabled: Bool) {
        settings = AppSettings(
            accentTheme: settings.accentTheme,
            defaultParkingType: settings.defaultParkingType,
            defaultReminderEnabled: enabled,
            defaultReminderOffsetMinutes: settings.defaultReminderOffsetMinutes
        )
        persist()
    }

    func updateDefaultReminderOffset(minutes: Int) {
        let clamped = max(15, min(24 * 60, minutes))
        settings = AppSettings(
            accentTheme: settings.accentTheme,
            defaultParkingType: settings.defaultParkingType,
            defaultReminderEnabled: settings.defaultReminderEnabled,
            defaultReminderOffsetMinutes: clamped
        )
        persist()
    }

    func replaceAll(with newSettings: AppSettings) {
        settings = newSettings
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: DefaultsKeys.appSettings)
        }
    }
}
