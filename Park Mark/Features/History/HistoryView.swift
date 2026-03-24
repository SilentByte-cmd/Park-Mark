import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var notificationService: ParkingNotificationService
    @EnvironmentObject private var locationManager: ParkPinLocationManager
    @EnvironmentObject private var geocodingService: GeocodingService

    @StateObject private var viewModel = HistoryViewModel()
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    @State private var spotPendingDeletion: UUID?
    @State private var formConfig: ParkingFormSheetConfig?

    private var visibleSpots: [ParkingSpot] {
        viewModel.filteredSpots(from: parkingStore.spots)
    }

    var body: some View {
        ZStack {
            PPGradientBackground()
            List {
                Section {
                    PPTextField(title: "Search title, address, or notes", text: $viewModel.searchText)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(HistoryFilterMode.allCases) { mode in
                                PPChip(
                                    title: mode.displayName,
                                    isSelected: viewModel.filter == mode,
                                    action: { viewModel.filter = mode }
                                )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                if visibleSpots.isEmpty {
                    Section {
                        PPEmptyState(
                            iconName: "tray",
                            title: parkingStore.spots.isEmpty ? "No history yet" : "No matches",
                            message: parkingStore.spots.isEmpty
                                ? "Your saved sessions will appear here with rich cards, filters, and sorting."
                                : "Try another search term or filter to see more results.",
                            actionTitle: parkingStore.spots.isEmpty ? "Save parking spot" : nil,
                            action: parkingStore.spots.isEmpty
                                ? {
                                    let draft = parkingStore.addNewDraftFromDefaults(settings: settingsStore.settings)
                                    formConfig = ParkingFormSheetConfig(spot: draft, isEditing: false)
                                }
                                : nil
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Section {
                        ForEach(visibleSpots) { spot in
                            NavigationLink {
                                ParkingDetailView(spotId: spot.id)
                            } label: {
                                HistoryParkingRow(spot: spot)
                            }
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    spotPendingDeletion = spot.id
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 20)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    }
                    .accessibilityLabel("Filters")

                    Button {
                        showSortSheet = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                    }
                    .accessibilityLabel("Sort")
                }
            }
        }
        .sheet(isPresented: $showSortSheet) {
            HistorySortSheet(selection: $viewModel.sort)
                .environmentObject(settingsStore)
        }
        .sheet(isPresented: $showFilterSheet) {
            HistoryFilterSheet(selection: $viewModel.filter)
                .environmentObject(settingsStore)
        }
        .sheet(item: $formConfig) { config in
            ParkingSpotFormView(initialSpot: config.spot, isEditing: config.isEditing)
                .environmentObject(parkingStore)
                .environmentObject(settingsStore)
                .environmentObject(notificationService)
                .environmentObject(locationManager)
                .environmentObject(geocodingService)
        }
        .confirmationDialog(
            "Delete this parking record?",
            isPresented: Binding(
                get: { spotPendingDeletion != nil },
                set: { newValue in
                    if !newValue {
                        spotPendingDeletion = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = spotPendingDeletion {
                    parkingStore.delete(id: id)
                }
                spotPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                spotPendingDeletion = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}
