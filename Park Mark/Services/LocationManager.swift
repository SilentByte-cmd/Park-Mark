import Combine
import CoreLocation
import Foundation

@MainActor
final class ParkPinLocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var lastCoordinate: CLLocationCoordinate2D?
    @Published private(set) var isFetchingLocation: Bool
    @Published private(set) var lastError: ParkPinLocationError?

    private let manager: CLLocationManager
    private var locationContinuation: CheckedContinuation<Result<CLLocationCoordinate2D, ParkPinLocationError>, Never>?

    override init() {
        let m = CLLocationManager()
        self.manager = m
        self.authorizationStatus = m.authorizationStatus
        self.isFetchingLocation = false
        super.init()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyBest
    }

    func clearError() {
        lastError = nil
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = manager.authorizationStatus
    }

    func requestWhenInUseAccessOnly() {
        manager.requestWhenInUseAuthorization()
    }

    func captureCurrentLocationOnce() async -> Result<CLLocationCoordinate2D, ParkPinLocationError> {
        clearError()
        guard CLLocationManager.locationServicesEnabled() else {
            let err = ParkPinLocationError.servicesDisabled
            lastError = err
            return .failure(err)
        }

        refreshAuthorizationStatus()

        switch manager.authorizationStatus {
        case .denied:
            let err = ParkPinLocationError.permissionDenied
            lastError = err
            return .failure(err)
        case .restricted:
            let err = ParkPinLocationError.restricted
            lastError = err
            return .failure(err)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            let updated = await waitForAuthorizationDecision()
            if updated == .notDetermined {
                let err = ParkPinLocationError.permissionDenied
                lastError = err
                return .failure(err)
            }
            return await captureCurrentLocationOnce()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            let err = ParkPinLocationError.locationUnavailable
            lastError = err
            return .failure(err)
        }

        isFetchingLocation = true
        lastCoordinate = nil

        let result: Result<CLLocationCoordinate2D, ParkPinLocationError> = await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            self.manager.requestLocation()
        }

        isFetchingLocation = false

        switch result {
        case .success(let coord):
            lastCoordinate = coord
            lastError = nil
        case .failure(let err):
            lastError = err
        }

        return result
    }

    private func waitForAuthorizationDecision() async -> CLAuthorizationStatus {
        for _ in 0..<80 {
            refreshAuthorizationStatus()
            let status = manager.authorizationStatus
            if status != .notDetermined {
                return status
            }
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
        refreshAuthorizationStatus()
        return manager.authorizationStatus
    }
}

extension ParkPinLocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            Task { @MainActor in
                self.completeLocation(with: .failure(.locationUnavailable))
            }
            return
        }
        guard coordinate.latitude.isFinite, coordinate.longitude.isFinite else {
            Task { @MainActor in
                self.completeLocation(with: .failure(.locationUnavailable))
            }
            return
        }
        Task { @MainActor in
            self.completeLocation(with: .success(coordinate))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let mapped: ParkPinLocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                mapped = .permissionDenied
            case .locationUnknown:
                mapped = .locationUnavailable
            default:
                mapped = .underlying(clError.localizedDescription)
            }
        } else {
            mapped = .underlying(error.localizedDescription)
        }
        Task { @MainActor in
            self.completeLocation(with: .failure(mapped))
        }
    }

    private func completeLocation(with result: Result<CLLocationCoordinate2D, ParkPinLocationError>) {
        locationContinuation?.resume(returning: result)
        locationContinuation = nil
    }
}
