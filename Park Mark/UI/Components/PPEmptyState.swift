import SwiftUI

struct PPEmptyState: View {
    let iconName: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.14))
                    .frame(width: 88, height: 88)
                Image(systemName: iconName)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            if let actionTitle, let action {
                PPPrimaryButton(title: actionTitle, isEnabled: true, action: action)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
    }
}
