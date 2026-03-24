import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingStore: OnboardingStore

    @State private var page: Int = 0

    private let slides = OnboardingSlideDefinition.slides

    var body: some View {
        ZStack {
            PPGradientBackground()
            VStack(spacing: 18) {
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        OnboardingSlidePage(slide: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                PPPageIndicator(count: slides.count, current: page)
                    .padding(.top, 4)

                PPPrimaryButton(
                    title: page >= slides.count - 1 ? "Get Started" : "Continue",
                    isEnabled: true,
                    action: advance
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func advance() {
        if page >= slides.count - 1 {
            onboardingStore.completeOnboarding()
        } else {
            page += 1
        }
    }
}
