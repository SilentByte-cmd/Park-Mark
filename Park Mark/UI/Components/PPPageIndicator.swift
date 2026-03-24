import SwiftUI

struct PPPageIndicator: View {
    let count: Int
    let current: Int

    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current
                          ? AppPalette.primary(for: settingsStore.settings.accentTheme)
                          : Color.primary.opacity(0.15))
                    .frame(width: index == current ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: current)
            }
        }
    }
}
