import CoreLocation
import Foundation

enum AppleMapsSearchURL {
    static func url(forParkingSpot spot: ParkingSpot) -> URL? {
        if spot.hasSavedCoordinates, let lat = spot.latitude, let lon = spot.longitude {
            let label = spot.trimmedAddress.isEmpty ? "Parked" : spot.trimmedAddress
            var allowed = CharacterSet.urlQueryAllowed
            allowed.remove("&")
            allowed.remove("+")
            let encodedLabel = label.addingPercentEncoding(withAllowedCharacters: allowed) ?? "Parked"
            return URL(string: "https://maps.apple.com/?ll=\(lat),\(lon)&q=\(encodedLabel)")
        }
        let query = spot.trimmedAddress.isEmpty ? spot.trimmedResolvedAddress : spot.trimmedAddress
        guard !query.isEmpty else { return nil }
        return url(forAddressQuery: query)
    }

    static func url(forAddressQuery query: String) -> URL? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("&")
        allowed.remove("+")
        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: allowed) ?? trimmed
        return URL(string: "https://maps.apple.com/?q=\(encoded)")
    }

    static func url(forCoordinate coordinate: CLLocationCoordinate2D, label: String = "Parked") -> URL? {
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove("&")
        allowed.remove("+")
        let encoded = label.addingPercentEncoding(withAllowedCharacters: allowed) ?? "Parked"
        return URL(string: "https://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(encoded)")
    }
}
