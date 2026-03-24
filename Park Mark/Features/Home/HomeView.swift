import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var notificationService: ParkingNotificationService
    @EnvironmentObject private var locationManager: ParkPinLocationManager
    @EnvironmentObject private var geocodingService: GeocodingService

    @StateObject private var viewModel = HomeViewModel()
    @State private var formConfig: ParkingFormSheetConfig?

    var body: some View {
        ZStack {
            PPGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if let active = parkingStore.activeSpot {
                        NavigationLink {
                            ParkingDetailView(spotId: active.id)
                        } label: {
                            ActiveSpotCard(spot: active, referenceDate: viewModel.tick)
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 12) {
                            PPSecondaryButton(title: "Edit session", isEnabled: true) {
                                formConfig = ParkingFormSheetConfig(spot: active, isEditing: true)
                            }
                            PPSecondaryButton(title: "New spot", isEnabled: true) {
                                let draft = parkingStore.addNewDraftFromDefaults(settings: settingsStore.settings)
                                formConfig = ParkingFormSheetConfig(spot: draft, isEditing: false)
                            }
                        }
                    } else {
                        PPEmptyState(
                            iconName: "mappin.and.ellipse",
                            title: "No active parking session",
                            message: "Save your spot in seconds. Park Pin keeps everything offline and ready when you return.",
                            actionTitle: "Save parking spot",
                            action: {
                                let draft = parkingStore.addNewDraftFromDefaults(settings: settingsStore.settings)
                                formConfig = ParkingFormSheetConfig(spot: draft, isEditing: false)
                            }
                        )
                    }

                    tipsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Park Pin")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let draft = parkingStore.addNewDraftFromDefaults(settings: settingsStore.settings)
                    formConfig = ParkingFormSheetConfig(spot: draft, isEditing: false)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                }
                .accessibilityLabel("Save new parking spot")
            }
        }
        .sheet(item: $formConfig) { config in
            ParkingSpotFormView(initialSpot: config.spot, isEditing: config.isEditing)
                .environmentObject(parkingStore)
                .environmentObject(settingsStore)
                .environmentObject(notificationService)
                .environmentObject(locationManager)
                .environmentObject(geocodingService)
        }
        .onAppear { viewModel.startLiveClock() }
        .onDisappear { viewModel.stopLiveClock() }
    }

    private var dailyTip: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = day % ParkingInsightTips.tips.count
        return ParkingInsightTips.tips[index]
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
            Text("Your calm return starts with one precise save.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.top, 4)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calm cues")
                .font(.headline.weight(.semibold))
            Text(dailyTip)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
        }
    }
}
