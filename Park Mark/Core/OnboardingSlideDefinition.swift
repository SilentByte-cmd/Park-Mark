import Foundation

struct OnboardingSlideDefinition: Identifiable {
    let id: String
    let title: String
    let message: String
    let symbolName: String

    static let slides: [OnboardingSlideDefinition] = [
        OnboardingSlideDefinition(
            id: "welcome",
            title: "Welcome to Park Pin",
            message: "Save where you parked in seconds, then return with calm confidence—completely offline.",
            symbolName: "parkingsign.circle.fill"
        ),
        OnboardingSlideDefinition(
            id: "save",
            title: "Save in seconds",
            message: "Capture title, location, level, and notes before you walk away—built for real garages and streets.",
            symbolName: "square.and.pencil"
        ),
        OnboardingSlideDefinition(
            id: "navigate",
            title: "Navigate back with confidence",
            message: "Find Car highlights the essentials when you are in a hurry—floor, zone, spot, and reminders.",
            symbolName: "location.fill"
        ),
        OnboardingSlideDefinition(
            id: "organize",
            title: "Organize your history",
            message: "Search, filter, and favorite past spots. Insights appear as your real data grows.",
            symbolName: "clock.arrow.circlepath"
        )
    ]
}
