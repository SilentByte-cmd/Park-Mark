import Foundation

extension ParkingSpot {
    private static let savedCurrentLocationPhrase = "Saved Current Location"

    var hasSavedCoordinates: Bool {
        guard let lat = latitude, let lon = longitude else { return false }
        return lat.isFinite && lon.isFinite && (-90...90).contains(lat) && (-180...180).contains(lon)
    }

    var trimmedAddress: String {
        address.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedResolvedAddress: String {
        resolvedAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displayLocationTitle: String {
        if !trimmedAddress.isEmpty {
            return trimmedAddress
        }
        if !trimmedResolvedAddress.isEmpty {
            return trimmedResolvedAddress
        }
        if hasSavedCoordinates {
            return Self.savedCurrentLocationPhrase
        }
        return ""
    }

    var displayLocationSubtitle: String? {
        if let subtitle = locationLineSubtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty {
            return subtitle
        }
        if locationSource == .deviceGPS, hasSavedCoordinates {
            if !trimmedAddress.isEmpty, !trimmedResolvedAddress.isEmpty, trimmedAddress != trimmedResolvedAddress {
                return trimmedResolvedAddress
            }
        }
        return nil
    }

    var coordinateLineForDisplay: String? {
        guard hasSavedCoordinates, let lat = latitude, let lon = longitude else { return nil }
        return String(format: "%.5f°, %.5f°", lat, lon)
    }

    var hasMeaningfulLocationForSave: Bool {
        if !trimmedAddress.isEmpty {
            return true
        }
        return hasSavedCoordinates
    }

    var canOpenInAppleMaps: Bool {
        hasSavedCoordinates || !trimmedAddress.isEmpty || !trimmedResolvedAddress.isEmpty
    }

    var copyableLocationText: String? {
        if !trimmedAddress.isEmpty {
            return trimmedAddress
        }
        if !trimmedResolvedAddress.isEmpty {
            return trimmedResolvedAddress
        }
        if let line = coordinateLineForDisplay {
            return line
        }
        return nil
    }

    var hasCopyableLocationText: Bool {
        copyableLocationText != nil
    }
}
