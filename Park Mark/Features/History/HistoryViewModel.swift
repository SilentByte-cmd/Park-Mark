import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filter: HistoryFilterMode = .all
    @Published var sort: HistorySortOption = .newestFirst

    func filteredSpots(from spots: [ParkingSpot]) -> [ParkingSpot] {
        var result = spots

        switch filter {
        case .all:
            break
        case .activeOnly:
            result = result.filter(\.isActive)
        case .favorites:
            result = result.filter(\.isFavorite)
        case .street:
            result = result.filter { $0.parkingType == .street }
        case .garage:
            result = result.filter { $0.parkingType == .garage }
        case .mall:
            result = result.filter { $0.parkingType == .mall }
        case .airport:
            result = result.filter { $0.parkingType == .airport }
        case .office:
            result = result.filter { $0.parkingType == .office }
        case .other:
            result = result.filter { $0.parkingType == .other }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { spot in
                spot.title.lowercased().contains(query)
                    || spot.address.lowercased().contains(query)
                    || spot.resolvedAddress.lowercased().contains(query)
                    || (spot.locationLineSubtitle?.lowercased().contains(query) ?? false)
                    || spot.note.lowercased().contains(query)
                    || (spot.coordinateLineForDisplay?.lowercased().contains(query) ?? false)
            }
        }

        switch sort {
        case .newestFirst:
            result.sort { $0.parkedAt > $1.parkedAt }
        case .oldestFirst:
            result.sort { $0.parkedAt < $1.parkedAt }
        case .favoritesFirst:
            result.sort { lhs, rhs in
                if lhs.isFavorite != rhs.isFavorite {
                    return lhs.isFavorite && !rhs.isFavorite
                }
                return lhs.parkedAt > rhs.parkedAt
            }
        case .activeFirst:
            result.sort { lhs, rhs in
                if lhs.isActive != rhs.isActive {
                    return lhs.isActive && !rhs.isActive
                }
                return lhs.parkedAt > rhs.parkedAt
            }
        }

        return result
    }
}
