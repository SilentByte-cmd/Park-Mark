import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var tick: Date = Date()

    private var cancellable: AnyCancellable?

    func startLiveClock() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick = date
            }
    }

    func stopLiveClock() {
        cancellable?.cancel()
        cancellable = nil
    }

    func activeDuration(from parkedAt: Date, reference: Date) -> TimeInterval {
        max(0, reference.timeIntervalSince(parkedAt))
    }

    func formattedDuration(from parkedAt: Date, reference: Date) -> String {
        let interval = activeDuration(from: parkedAt, reference: reference)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0s"
    }
}
