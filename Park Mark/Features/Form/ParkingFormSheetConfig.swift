import Foundation

struct ParkingFormSheetConfig: Identifiable {
    let id = UUID()
    let spot: ParkingSpot
    let isEditing: Bool
}
