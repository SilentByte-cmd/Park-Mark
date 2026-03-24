import SwiftUI

enum AppAccentTheme: String, CaseIterable, Identifiable, Codable {
    case emerald
    case warmAmber
    case violetBloom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .emerald: return "Emerald"
        case .warmAmber: return "Warm Amber"
        case .violetBloom: return "Violet Bloom"
        }
    }
}
