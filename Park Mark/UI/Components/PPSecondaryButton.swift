import SwiftUI

struct PPSecondaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(isEnabled ? 1 : 0.45), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppPalette.surfaceSubtle(for: colorScheme))
                        )
                )
                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(isEnabled ? 1 : 0.45))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
