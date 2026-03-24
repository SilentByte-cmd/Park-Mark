import Foundation
import Combine

@MainActor
final class FindCarViewModel: ObservableObject {
    @Published private(set) var now: Date = Date()

    private var cancellable: AnyCancellable?

    func startClock() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
            }
    }

    func stopClock() {
        cancellable?.cancel()
        cancellable = nil
    }

    func reminderStatus(for spot: ParkingSpot, now: Date) -> String? {
        guard let end = spot.reminderEndTime else { return nil }
        if end < now {
            return "Reminder time passed"
        }
        return "Reminder at \(end.parkPinMediumString())"
    }
}
