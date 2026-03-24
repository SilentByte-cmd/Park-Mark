import Combine
import Foundation
import SwiftUI

@MainActor
final class ParkingSpotStore: ObservableObject {
    @Published private(set) var spots: [ParkingSpot] = []

    private let defaults: UserDefaults
    private let notificationService: ParkingNotificationService

    init(defaults: UserDefaults = .standard, notificationService: ParkingNotificationService) {
        self.defaults = defaults
        self.notificationService = notificationService
        load()
    }

    var activeSpot: ParkingSpot? {
        spots.first { $0.isActive }
    }

    func load() {
        guard let data = defaults.data(forKey: DefaultsKeys.parkingSpots),
              let decoded = try? JSONDecoder().decode([ParkingSpot].self, from: data) else {
            spots = []
            return
        }
        spots = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(spots) {
            defaults.set(data, forKey: DefaultsKeys.parkingSpots)
        }
    }

    private func index(of id: UUID) -> Int? {
        spots.firstIndex { $0.id == id }
    }

    func upsert(_ spot: ParkingSpot) {
        if let idx = index(of: spot.id) {
            spots[idx] = spot
        } else {
            spots.insert(spot, at: 0)
        }
        if spot.isActive {
            deactivateAllExcept(spot.id)
        }
        persist()
        syncReminder(for: spot)
    }

    func addNewDraftFromDefaults(settings: AppSettings) -> ParkingSpot {
        let marker = ParkingMarkerCatalog.defaultStyle
        var reminder: Date?
        if settings.defaultReminderEnabled {
            reminder = Date().addingTimeInterval(TimeInterval(settings.defaultReminderOffsetMinutes * 60))
        }
        return ParkingSpot(
            title: "",
            address: "",
            parkingType: settings.defaultParkingType,
            parkedAt: Date(),
            reminderEndTime: reminder,
            markerStyle: marker,
            isActive: true,
            createdAt: Date()
        )
    }

    func delete(id: UUID) {
        spots.removeAll { $0.id == id }
        notificationService.cancelReminder(for: id)
        persist()
    }

    func deleteAll() {
        spots.removeAll()
        notificationService.cancelAllReminders()
        persist()
    }

    func spot(id: UUID) -> ParkingSpot? {
        spots.first { $0.id == id }
    }

    func endSession(id: UUID) {
        guard let idx = index(of: id) else { return }
        spots[idx].isActive = false
        spots[idx].endedAt = Date()
        notificationService.cancelReminder(for: id)
        persist()
    }

    func reactivate(id: UUID) {
        guard let idx = index(of: id) else { return }
        deactivateAllExcept(id)
        spots[idx].isActive = true
        spots[idx].endedAt = nil
        persist()
        syncReminder(for: spots[idx])
    }

    func toggleFavorite(id: UUID) {
        guard let idx = index(of: id) else { return }
        spots[idx].isFavorite.toggle()
        persist()
    }

    func duplicate(id: UUID) {
        guard let original = spot(id: id) else { return }
        var copy = original
        copy.id = UUID()
        copy.createdAt = Date()
        copy.isActive = false
        copy.endedAt = nil
        copy.parkedAt = Date()
        spots.insert(copy, at: 0)
        persist()
    }

    private func deactivateAllExcept(_ id: UUID) {
        for idx in spots.indices where spots[idx].id != id && spots[idx].isActive {
            spots[idx].isActive = false
            if spots[idx].endedAt == nil {
                spots[idx].endedAt = Date()
            }
            notificationService.cancelReminder(for: spots[idx].id)
        }
    }

    private func syncReminder(for spot: ParkingSpot) {
        notificationService.cancelReminder(for: spot.id)
        guard spot.isActive, let end = spot.reminderEndTime, end > Date() else { return }
        notificationService.scheduleReminder(for: spot)
    }

    func rescheduleAllActiveReminders() {
        for spot in spots where spot.isActive {
            syncReminder(for: spot)
        }
    }
}
