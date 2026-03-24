import SwiftUI

struct OnboardingSlidePage: View {
    let slide: OnboardingSlideDefinition

    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.16))
                    .frame(width: 120, height: 120)
                Image(systemName: slide.symbolName)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
            }

            VStack(spacing: 10) {
                Text(slide.title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(slide.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            Spacer()
        }
        .padding(.horizontal, 18)
    }
}
