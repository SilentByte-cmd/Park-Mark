import SwiftUI

struct PPToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }
}
