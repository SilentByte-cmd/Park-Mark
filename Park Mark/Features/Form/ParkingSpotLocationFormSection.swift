import CoreLocation
import SwiftUI

struct ParkingSpotLocationFormSection: View {
    @ObservedObject var formViewModel: ParkingSpotFormViewModel

    @EnvironmentObject private var locationManager: ParkPinLocationManager
    @EnvironmentObject private var geocodingService: GeocodingService
    @EnvironmentObject private var settingsStore: AppSettingsStore

    @State private var attachSucceeded = false
    @State private var inlineMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            PPFormSectionHeader(title: "Location")

            PPLocationPermissionCallout(
                status: locationManager.authorizationStatus,
                systemLocationServicesEnabled: CLLocationManager.locationServicesEnabled(),
                onOpenSettings: { AppSettingsOpener.openAppSettings() }
            )

            if locationManager.isFetchingLocation {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    Text("Finding your current position…")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
            }

            Button(action: { Task { await useCurrentLocation() } }) {
                HStack(spacing: 10) {
                    Image(systemName: "location.fill")
                        .font(.body.weight(.semibold))
                    Text("Use Current Location")
                        .font(.headline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(locationButtonEnabled ? 1 : 0.35))
                )
                .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain)
            .disabled(!locationButtonEnabled)

            if attachSucceeded, formViewModel.draft.hasSavedCoordinates {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    Text("Location attached")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 4)
            }

            if let inlineMessage {
                Text(inlineMessage)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
            }

            if let err = locationManager.lastError {
                Text(err.userMessage)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            PPTextField(title: "Address / location", text: $formViewModel.draft.address, axis: .vertical)

            if formViewModel.draft.hasSavedCoordinates {
                Button("Clear GPS pin") {
                    formViewModel.draft.latitude = nil
                    formViewModel.draft.longitude = nil
                    formViewModel.draft.resolvedAddress = ""
                    formViewModel.draft.locationSource = .manual
                    formViewModel.draft.locationLineSubtitle = nil
                    attachSucceeded = false
                    inlineMessage = nil
                    locationManager.clearError()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            locationManager.refreshAuthorizationStatus()
        }
    }

    private var locationButtonEnabled: Bool {
        !locationManager.isFetchingLocation
            && CLLocationManager.locationServicesEnabled()
            && locationManager.authorizationStatus != .restricted
            && locationManager.authorizationStatus != .denied
    }

    private func useCurrentLocation() async {
        attachSucceeded = false
        inlineMessage = nil
        locationManager.clearError()

        let result = await locationManager.captureCurrentLocationOnce()
        switch result {
        case .failure:
            return
        case .success(let coordinate):
            formViewModel.draft.latitude = coordinate.latitude
            formViewModel.draft.longitude = coordinate.longitude
            formViewModel.draft.locationSource = .deviceGPS

            let place = await geocodingService.reverseGeocode(coordinate: coordinate)
            if let formatted = place.formattedAddress, !formatted.isEmpty {
                formViewModel.draft.resolvedAddress = formatted
                formViewModel.draft.address = formatted
                formViewModel.draft.locationLineSubtitle = place.localitySubtitle
                inlineMessage = nil
            } else {
                formViewModel.draft.resolvedAddress = ""
                formViewModel.draft.address = "Saved Current Location"
                formViewModel.draft.locationLineSubtitle = place.localitySubtitle
                inlineMessage = "We saved your coordinates. Add more detail in the address field if you want."
            }
            attachSucceeded = true
        }
    }
}
