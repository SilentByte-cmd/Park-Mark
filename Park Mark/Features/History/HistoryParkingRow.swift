import SwiftUI

struct HistoryParkingRow: View {
    let spot: ParkingSpot

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppPalette.surfaceSubtle(for: colorScheme))
                    .frame(width: 52, height: 52)
                Image(systemName: spot.markerStyle.symbolName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppPalette.markerAccent(colorIndex: spot.markerStyle.colorIndex, theme: settingsStore.settings.accentTheme))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(spot.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    if spot.isActive {
                        Text("Active")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.18))
                            .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                            .clipShape(Capsule())
                    }
                    if spot.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    }
                }

                Text(spot.displayLocationTitle.isEmpty ? "—" : spot.displayLocationTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Label(spot.parkingType.displayName, systemImage: spot.parkingType.symbolName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(spot.parkedAt.parkPinMediumString())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppPalette.surfaceElevated(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
        )
        .parkPinSoftShadow()
    }
}
