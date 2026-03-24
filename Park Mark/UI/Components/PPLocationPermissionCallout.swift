import CoreLocation
import SwiftUI

struct PPLocationPermissionCallout: View {
    let status: CLAuthorizationStatus
    let systemLocationServicesEnabled: Bool
    let onOpenSettings: () -> Void

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if !systemLocationServicesEnabled {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "location.slash.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location Services Are Off")
                            .font(.headline.weight(.semibold))
                        Text("Turn on Location Services in Settings, then return here to drop a pin. You can still type an address manually.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Button(action: onOpenSettings) {
                    Text("Open Settings")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppPalette.primary(for: settingsStore.settings.accentTheme))
                        )
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppPalette.surfaceElevated(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
            )
        }

        if shouldShow {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "location.slash.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location Access Needed")
                            .font(.headline.weight(.semibold))
                        Text(
                            status == .restricted
                                ? "This device prevents Park Pin from using location. You can still type an address manually."
                                : "Allow location when prompted, or enable it in Settings so we can drop a precise pin for this spot."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }

                if status == .denied {
                    Button(action: onOpenSettings) {
                        Text("Open Settings")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppPalette.primary(for: settingsStore.settings.accentTheme))
                            )
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppPalette.surfaceElevated(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
            )
        }
    }

    private var shouldShow: Bool {
        status == .denied || status == .restricted
    }
}
