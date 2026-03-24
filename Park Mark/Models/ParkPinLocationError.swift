import Foundation

enum ParkPinLocationError: Error, Equatable {
    case permissionDenied
    case restricted
    case servicesDisabled
    case locationUnavailable
    case geocodeFailed
    case underlying(String)

    var userMessage: String {
        switch self {
        case .permissionDenied:
            return "Location access is turned off for Park Pin."
        case .restricted:
            return "Location is restricted on this device."
        case .servicesDisabled:
            return "Location services are disabled. Turn them on in Settings."
        case .locationUnavailable:
            return "We could not read your position. Try again or enter the address manually."
        case .geocodeFailed:
            return "We saved your coordinates but could not resolve a street address."
        case .underlying(let message):
            return message
        }
    }
}
