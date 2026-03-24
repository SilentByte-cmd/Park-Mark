import Combine
import Contacts
import CoreLocation
import Foundation

@MainActor
final class GeocodingService: ObservableObject {
    private let geocoder = CLGeocoder()

    func cancel() {
        geocoder.cancelGeocode()
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> GeocodedPlace {
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return GeocodedPlace(formattedAddress: nil, localitySubtitle: nil)
        }
        geocoder.cancelGeocode()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                guard let place = placemarks?.first else {
                    continuation.resume(returning: GeocodedPlace(formattedAddress: nil, localitySubtitle: nil))
                    return
                }
                let formatted = Self.composeAddress(from: place)
                let localityParts = [place.locality, place.administrativeArea].compactMap { $0 }.filter { !$0.isEmpty }
                let subtitle = localityParts.isEmpty ? nil : localityParts.joined(separator: ", ")
                continuation.resume(returning: GeocodedPlace(formattedAddress: formatted, localitySubtitle: subtitle))
            }
        }
    }

    private static func composeAddress(from placemark: CLPlacemark) -> String? {
        if let formatted = placemark.postalAddress {
            let formatter = CNPostalAddressFormatter()
            let single = formatter.string(from: formatted).replacingOccurrences(of: "\n", with: ", ")
            let collapsed = single.replacingOccurrences(of: ", ,", with: ",")
            let trimmed = collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        let parts = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode
        ].compactMap { $0 }.filter { !$0.isEmpty }
        if parts.isEmpty {
            return placemark.name
        }
        return parts.joined(separator: ", ")
    }
}
