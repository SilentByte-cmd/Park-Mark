import SwiftUI

struct PPChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(chipBackground)
                .foregroundStyle(foreground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppPalette.stroke(for: colorScheme), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var chipBackground: some View {
        Group {
            if isSelected {
                AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.22)
            } else {
                AppPalette.surfaceElevated(for: colorScheme)
            }
        }
    }

    private var foreground: Color {
        if isSelected {
            return AppPalette.primary(for: settingsStore.settings.accentTheme)
        }
        return Color.primary.opacity(0.85)
    }
}
