import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    struct Summary {
        let totalSpots: Int
        let activeSpots: Int
        let favoriteSpots: Int
        let mostUsedType: ParkingType?
        let weekCount: Int
        let monthCount: Int
        let averageCompletedDuration: TimeInterval?
    }

    func buildSummary(spots: [ParkingSpot], now: Date = Date()) -> Summary {
        let total = spots.count
        let active = spots.filter(\.isActive).count
        let favorites = spots.filter(\.isFavorite).count

        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now

        let weekCount = spots.filter { $0.createdAt >= weekAgo }.count
        let monthCount = spots.filter { $0.createdAt >= monthAgo }.count

        let typeCounts = Dictionary(grouping: spots, by: \.parkingType).mapValues { $0.count }
        let mostUsed = typeCounts.max(by: { $0.value < $1.value })?.key

        let completedDurations: [TimeInterval] = spots.compactMap { spot in
            guard !spot.isActive, let ended = spot.endedAt else { return nil }
            return ended.timeIntervalSince(spot.parkedAt)
        }
        let averageDuration: TimeInterval?
        if completedDurations.isEmpty {
            averageDuration = nil
        } else {
            averageDuration = completedDurations.reduce(0, +) / Double(completedDurations.count)
        }

        return Summary(
            totalSpots: total,
            activeSpots: active,
            favoriteSpots: favorites,
            mostUsedType: mostUsed,
            weekCount: weekCount,
            monthCount: monthCount,
            averageCompletedDuration: averageDuration
        )
    }

    func formatDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter.string(from: interval) ?? "—"
    }
}
