import SwiftUI

struct ActiveSpotCard: View {
    let spot: ParkingSpot
    let referenceDate: Date

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    private var durationText: String {
        let interval = max(0, referenceDate.timeIntervalSince(spot.parkedAt))
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppPalette.surfaceSubtle(for: colorScheme))
                        .frame(width: 54, height: 54)
                    Image(systemName: spot.markerStyle.symbolName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(AppPalette.markerAccent(colorIndex: spot.markerStyle.colorIndex, theme: settingsStore.settings.accentTheme))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current session")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    Text(spot.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    HStack(alignment: .top, spacing: 8) {
                        if spot.hasSavedCoordinates || spot.locationSource == .deviceGPS {
                            Image(systemName: "location.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.displayLocationTitle.isEmpty ? "Add a location" : spot.displayLocationTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                            if let subtitle = spot.displayLocationSubtitle {
                                Text(subtitle)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                detailPill(title: "Parked", value: spot.parkedAt.parkPinMediumString())
                detailPill(title: "Duration", value: durationText)
            }

            if !spot.floor.isEmpty || !spot.zone.isEmpty || !spot.spotNumber.isEmpty {
                HStack(spacing: 10) {
                    if !spot.floor.isEmpty {
                        detailPill(title: "Floor", value: spot.floor)
                    }
                    if !spot.zone.isEmpty {
                        detailPill(title: "Zone", value: spot.zone)
                    }
                    if !spot.spotNumber.isEmpty {
                        detailPill(title: "Spot", value: spot.spotNumber)
                    }
                }
            }

            if let reminder = spot.reminderEndTime {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    Text("Reminder at \(reminder.parkPinMediumString())")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppPalette.surfaceElevated(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
        )
        .parkPinCardShadow()
    }

    private func detailPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }
}
