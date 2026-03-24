import Combine
import Foundation
import SwiftUI

@MainActor
final class OnboardingStore: ObservableObject {
    @Published private(set) var state: OnboardingState

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: DefaultsKeys.onboarding),
           let decoded = try? JSONDecoder().decode(OnboardingState.self, from: data) {
            state = decoded
        } else {
            state = .initial
        }
    }

    var hasCompletedOnboarding: Bool {
        state.hasCompletedOnboarding
    }

    func completeOnboarding() {
        state = OnboardingState(hasCompletedOnboarding: true)
        persist()
    }

    func resetOnboarding() {
        state = .initial
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: DefaultsKeys.onboarding)
        }
    }
}
