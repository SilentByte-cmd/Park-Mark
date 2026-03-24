import Foundation

enum HistoryFilterMode: String, CaseIterable, Identifiable, Codable {
    case all
    case activeOnly
    case favorites
    case street
    case garage
    case mall
    case airport
    case office
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .activeOnly: return "Active"
        case .favorites: return "Favorites"
        case .street: return "Street"
        case .garage: return "Garage"
        case .mall: return "Mall"
        case .airport: return "Airport"
        case .office: return "Office"
        case .other: return "Other"
        }
    }
}
