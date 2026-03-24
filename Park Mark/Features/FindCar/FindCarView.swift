import SwiftUI
import UIKit

struct FindCarView: View {
    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore

    @StateObject private var viewModel = FindCarViewModel()
    @State private var showCopyConfirmation = false
    @State private var mapsError = false

    var body: some View {
        ZStack {
            PPGradientBackground()
            if let spot = parkingStore.activeSpot {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(spot.title)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(spot.displayLocationTitle.isEmpty ? "Location not set" : spot.displayLocationTitle)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    if let subtitle = spot.displayLocationSubtitle {
                                        Text(subtitle)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.tertiary)
                                    }
                                    if let coord = spot.coordinateLineForDisplay {
                                        Text(coord)
                                            .font(.footnote.monospacedDigit())
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                        }

                        bigBlock(title: "Floor", value: spot.floor.isEmpty ? "—" : spot.floor)
                        bigBlock(title: "Zone", value: spot.zone.isEmpty ? "—" : spot.zone)
                        bigBlock(title: "Spot", value: spot.spotNumber.isEmpty ? "—" : spot.spotNumber)

                        if !spot.note.isEmpty {
                            PPCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Note")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    Text(spot.note)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }

                        parkedSince(spot: spot)

                        if let reminderText = viewModel.reminderStatus(for: spot, now: viewModel.now) {
                            PPCard {
                                HStack(spacing: 10) {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                                    Text(reminderText)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }

                        PPPrimaryButton(title: "I Found My Car", isEnabled: true) {
                            parkingStore.endSession(id: spot.id)
                        }

                        HStack(spacing: 12) {
                            PPSecondaryButton(title: "Copy Address", isEnabled: spot.hasCopyableLocationText) {
                                if let text = spot.copyableLocationText {
                                    PasteboardCopier.copy(text)
                                    showCopyConfirmation = true
                                }
                            }
                            PPSecondaryButton(title: "Open in Maps", isEnabled: spot.canOpenInAppleMaps) {
                                openMaps(for: spot)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)
            } else {
                PPEmptyState(
                    iconName: "car.side.lock.open.fill",
                    title: "No active session",
                    message: "Save a spot from Home or History to unlock a focused return experience.",
                    actionTitle: nil,
                    action: nil
                )
                .padding(.horizontal, 12)
            }
        }
        .navigationTitle("Find Car")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.startClock() }
        .onDisappear { viewModel.stopClock() }
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

    private func bigBlock(title: String, value: String) -> some View {
        PPCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
    }

    private func parkedSince(spot: ParkingSpot) -> some View {
        let interval = max(0, viewModel.now.timeIntervalSince(spot.parkedAt))
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let text = formatter.string(from: interval) ?? "0s"

        return PPCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Parked since")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(spot.parkedAt.parkPinMediumString())
                    .font(.headline.weight(.semibold))
                Text("Elapsed \(text)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
