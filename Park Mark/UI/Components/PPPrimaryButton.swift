import SwiftUI

struct PPPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(isEnabled ? 1 : 0.35))
                )
                .foregroundStyle(Color.white)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
