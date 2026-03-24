import Foundation

enum ParkingType: String, CaseIterable, Identifiable, Codable {
    case street
    case garage
    case mall
    case airport
    case office
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .street: return "Street"
        case .garage: return "Garage"
        case .mall: return "Mall"
        case .airport: return "Airport"
        case .office: return "Office"
        case .other: return "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .street: return "road.lanes"
        case .garage: return "building.columns.fill"
        case .mall: return "bag.fill"
        case .airport: return "airplane"
        case .office: return "briefcase.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
