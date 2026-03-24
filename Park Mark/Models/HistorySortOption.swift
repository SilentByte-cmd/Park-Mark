import Foundation

enum HistorySortOption: String, CaseIterable, Identifiable, Codable {
    case newestFirst
    case oldestFirst
    case favoritesFirst
    case activeFirst

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newestFirst: return "Newest"
        case .oldestFirst: return "Oldest"
        case .favoritesFirst: return "Favorites"
        case .activeFirst: return "Active"
        }
    }
}
