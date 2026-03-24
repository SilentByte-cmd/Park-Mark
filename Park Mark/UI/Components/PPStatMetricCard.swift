import SwiftUI

struct PPStatMetricCard: View {
    let title: String
    let value: String
    let caption: String

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppPalette.surfaceElevated(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
        )
        .parkPinSoftShadow()
    }
}
