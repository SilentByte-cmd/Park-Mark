import SwiftUI

enum AppPalette {
    static func primary(for theme: AppAccentTheme) -> Color {
        switch theme {
        case .emerald:
            return Color(red: 0.10, green: 0.72, blue: 0.52)
        case .warmAmber:
            return Color(red: 0.93, green: 0.62, blue: 0.22)
        case .violetBloom:
            return Color(red: 0.58, green: 0.38, blue: 0.92)
        }
    }

    static func secondary(for theme: AppAccentTheme) -> Color {
        switch theme {
        case .emerald:
            return Color(red: 0.14, green: 0.52, blue: 0.42)
        case .warmAmber:
            return Color(red: 0.72, green: 0.45, blue: 0.16)
        case .violetBloom:
            return Color(red: 0.42, green: 0.28, blue: 0.78)
        }
    }

    static func surfaceElevated(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.92)
    }

    static func surfaceSubtle(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.04)
    }

    static func stroke(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)
    }

    static func backgroundGradientTop(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.07, green: 0.08, blue: 0.10) : Color(red: 0.95, green: 0.96, blue: 0.97)
    }

    static func backgroundGradientBottom(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0.04, green: 0.05, blue: 0.07) : Color(red: 0.90, green: 0.92, blue: 0.94)
    }

    static func markerAccent(colorIndex: Int, theme: AppAccentTheme) -> Color {
        let palette: [Color]
        switch theme {
        case .emerald:
            palette = [
                Color(red: 0.10, green: 0.72, blue: 0.52),
                Color(red: 0.20, green: 0.55, blue: 0.48),
                Color(red: 0.35, green: 0.78, blue: 0.62),
                Color(red: 0.12, green: 0.45, blue: 0.55),
                Color(red: 0.55, green: 0.82, blue: 0.45),
                Color(red: 0.18, green: 0.62, blue: 0.70)
            ]
        case .warmAmber:
            palette = [
                Color(red: 0.93, green: 0.62, blue: 0.22),
                Color(red: 0.85, green: 0.48, blue: 0.18),
                Color(red: 0.96, green: 0.74, blue: 0.38),
                Color(red: 0.72, green: 0.42, blue: 0.20),
                Color(red: 0.98, green: 0.55, blue: 0.30),
                Color(red: 0.78, green: 0.58, blue: 0.28)
            ]
        case .violetBloom:
            palette = [
                Color(red: 0.58, green: 0.38, blue: 0.92),
                Color(red: 0.46, green: 0.30, blue: 0.82),
                Color(red: 0.72, green: 0.52, blue: 0.95),
                Color(red: 0.38, green: 0.24, blue: 0.68),
                Color(red: 0.62, green: 0.45, blue: 0.98),
                Color(red: 0.50, green: 0.36, blue: 0.78)
            ]
        }
        let idx = abs(colorIndex) % palette.count
        return palette[idx]
    }
}
