import Foundation

struct OnboardingState: Codable, Equatable {
    var hasCompletedOnboarding: Bool

    static let initial = OnboardingState(hasCompletedOnboarding: false)
}
