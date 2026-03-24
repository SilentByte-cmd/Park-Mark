import SwiftUI
import UIKit

struct ParkingDetailView: View {
    let spotId: UUID

    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var notificationService: ParkingNotificationService
    @EnvironmentObject private var locationManager: ParkPinLocationManager
    @EnvironmentObject private var geocodingService: GeocodingService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var formConfig: ParkingFormSheetConfig?
    @State private var showDeleteConfirmation = false
    @State private var showCopyConfirmation = false
    @State private var mapsError = false

    private var spot: ParkingSpot? {
        parkingStore.spot(id: spotId)
    }

    var body: some View {
        Group {
            if let spot {
                detailContent(spot)
            } else {
                missingContent
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $formConfig) { config in
            ParkingSpotFormView(initialSpot: config.spot, isEditing: config.isEditing)
                .environmentObject(parkingStore)
                .environmentObject(settingsStore)
                .environmentObject(notificationService)
                .environmentObject(locationManager)
                .environmentObject(geocodingService)
        }
        .alert("Delete this parking record?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                parkingStore.delete(id: spotId)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .alert("Address copied", isPresented: $showCopyConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Paste it anywhere you need it.")
        }
        .alert("Unable to open Maps", isPresented: $mapsError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check the address and try again.")
        }
    }

    private var missingContent: some View {
        ZStack {
            PPGradientBackground()
            PPEmptyState(
                iconName: "exclamationmark.triangle",
                title: "Record unavailable",
                message: "This parking record may have been removed.",
                actionTitle: nil,
                action: nil
            )
        }
    }

    private func detailContent(_ spot: ParkingSpot) -> some View {
        ZStack {
            PPGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero(spot)
                    locationCard(spot)
                    metaCard(spot)
                    noteCard(spot)
                    actions(spot)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func hero(_ spot: ParkingSpot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: spot.markerStyle.symbolName)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(AppPalette.markerAccent(colorIndex: spot.markerStyle.colorIndex, theme: settingsStore.settings.accentTheme))
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.title)
                        .font(.title2.weight(.bold))
                    Text(spot.displayLocationTitle.isEmpty ? "—" : spot.displayLocationTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let subtitle = spot.displayLocationSubtitle {
                        Text(subtitle)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer(minLength: 0)
            }

            if let data = spot.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
                    )
            }
        }
    }

    private func locationCard(_ spot: ParkingSpot) -> some View {
        Group {
            if !spot.displayLocationTitle.isEmpty || spot.hasSavedCoordinates {
                PPCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                            Text("Location")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            if spot.locationSource == .deviceGPS {
                                Text("GPS")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.16))
                                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                                    .clipShape(Capsule())
                            }
                        }
                        Text(spot.displayLocationTitle.isEmpty ? "Saved Current Location" : spot.displayLocationTitle)
                            .font(.body.weight(.semibold))
                        if let subtitle = spot.displayLocationSubtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let coord = spot.coordinateLineForDisplay {
                            Text(coord)
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }

    private func metaCard(_ spot: ParkingSpot) -> some View {
        PPCard {
            VStack(alignment: .leading, spacing: 12) {
                row(label: "Status", value: spot.isActive ? "Active session" : "Completed")
                row(label: "Type", value: spot.parkingType.displayName)
                row(label: "Parked at", value: spot.parkedAt.parkPinMediumString())
                if let ended = spot.endedAt {
                    row(label: "Ended at", value: ended.parkPinMediumString())
                }
                if let reminder = spot.reminderEndTime {
                    row(label: "Reminder", value: reminder.parkPinMediumString())
                }
                if let nick = spot.vehicleNickname, !nick.isEmpty {
                    row(label: "Vehicle", value: nick)
                }
                row(label: "Favorite", value: spot.isFavorite ? "Yes" : "No")
                row(label: "Created", value: spot.createdAt.parkPinMediumString())
                if !spot.floor.isEmpty {
                    row(label: "Floor", value: spot.floor)
                }
                if !spot.zone.isEmpty {
                    row(label: "Zone", value: spot.zone)
                }
                if !spot.spotNumber.isEmpty {
                    row(label: "Spot", value: spot.spotNumber)
                }
            }
        }
    }

    private func row(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func noteCard(_ spot: ParkingSpot) -> some View {
        Group {
            if !spot.note.isEmpty {
                PPCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(spot.note)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    private func actions(_ spot: ParkingSpot) -> some View {
        VStack(spacing: 12) {
            PPPrimaryButton(title: "Edit", isEnabled: true) {
                formConfig = ParkingFormSheetConfig(spot: spot, isEditing: true)
            }

            PPSecondaryButton(title: "Duplicate", isEnabled: true) {
                parkingStore.duplicate(id: spot.id)
            }

            PPSecondaryButton(title: spot.isFavorite ? "Remove favorite" : "Mark favorite", isEnabled: true) {
                parkingStore.toggleFavorite(id: spot.id)
            }

            if spot.isActive {
                PPPrimaryButton(title: "Mark as found / end session", isEnabled: true) {
                    parkingStore.endSession(id: spot.id)
                }
            } else {
                PPSecondaryButton(title: "Reactivate as current spot", isEnabled: true) {
                    parkingStore.reactivate(id: spot.id)
                }
            }

            PPSecondaryButton(title: "Copy Address", isEnabled: spot.hasCopyableLocationText) {
                if let text = spot.copyableLocationText {
                    PasteboardCopier.copy(text)
                    showCopyConfirmation = true
                }
            }

            PPSecondaryButton(title: "Open in Maps", isEnabled: spot.canOpenInAppleMaps) {
                openMaps(for: spot)
            }

            PPSecondaryButton(title: "Delete", isEnabled: true) {
                showDeleteConfirmation = true
            }
        }
    }

    private func openMaps(for spot: ParkingSpot) {
        guard let url = AppleMapsSearchURL.url(forParkingSpot: spot) else {
            mapsError = true
            return
        }
        UIApplication.shared.open(url) { success in
            if !success {
                DispatchQueue.main.async {
                    mapsError = true
                }
            }
        }
    }
}
