import Combine
import Foundation
import SwiftUI

@MainActor
final class ParkingSpotFormViewModel: ObservableObject {
    @Published var draft: ParkingSpot
    @Published var reminderEnabled: Bool

    private let originalId: UUID

    var isEditing: Bool

    init(spot: ParkingSpot, isEditing: Bool) {
        self.draft = spot
        self.originalId = spot.id
        self.isEditing = isEditing
        self.reminderEnabled = spot.reminderEndTime != nil
    }

    var isValid: Bool {
        let titleOk = !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return titleOk && draft.hasMeaningfulLocationForSave
    }

    func applyReminderToggle(defaultOffsetMinutes: Int) {
        if reminderEnabled {
            if draft.reminderEndTime == nil {
                draft.reminderEndTime = draft.parkedAt.addingTimeInterval(TimeInterval(defaultOffsetMinutes * 60))
            }
        } else {
            draft.reminderEndTime = nil
        }
    }

    func normalizedDraft() -> ParkingSpot {
        var copy = draft
        copy.id = originalId
        copy.title = copy.title.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.address = copy.address.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.resolvedAddress = copy.resolvedAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if copy.latitude == nil || copy.longitude == nil {
            copy.latitude = nil
            copy.longitude = nil
        }
        if !copy.hasSavedCoordinates {
            copy.locationSource = .manual
            copy.resolvedAddress = ""
        } else if copy.locationSource == .manual {
            copy.locationSource = .deviceGPS
        }
        if let sub = copy.locationLineSubtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !sub.isEmpty {
            copy.locationLineSubtitle = sub
        } else {
            copy.locationLineSubtitle = nil
        }
        copy.floor = copy.floor.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.zone = copy.zone.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.spotNumber = copy.spotNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.note = copy.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let nick = copy.vehicleNickname?.trimmingCharacters(in: .whitespacesAndNewlines), !nick.isEmpty {
            copy.vehicleNickname = nick
        } else {
            copy.vehicleNickname = nil
        }
        if !reminderEnabled {
            copy.reminderEndTime = nil
        }
        return copy
    }
}
