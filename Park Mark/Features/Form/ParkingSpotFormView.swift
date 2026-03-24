import SwiftUI
import PhotosUI
import UIKit

struct ParkingSpotFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var notificationService: ParkingNotificationService

    @StateObject private var viewModel: ParkingSpotFormViewModel

    @State private var photoItem: PhotosPickerItem?
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    init(initialSpot: ParkingSpot, isEditing: Bool) {
        _viewModel = StateObject(wrappedValue: ParkingSpotFormViewModel(spot: initialSpot, isEditing: isEditing))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PPGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        photoSection
                        PPFormSectionHeader(title: "Essentials")
                        PPTextField(title: "Title", text: $viewModel.draft.title)
                        ParkingSpotLocationFormSection(formViewModel: viewModel)

                        PPFormSectionHeader(title: "Parking layout")
                        PPTextField(title: "Floor (optional)", text: $viewModel.draft.floor)
                        PPTextField(title: "Zone (optional)", text: $viewModel.draft.zone)
                        PPTextField(title: "Spot number (optional)", text: $viewModel.draft.spotNumber)

                        PPFormSectionHeader(title: "Type")
                        parkingTypeChips

                        PPFormSectionHeader(title: "Timing")
                        timingCard

                        PPFormSectionHeader(title: "Reminder")
                        reminderSection

                        PPFormSectionHeader(title: "Vehicle")
                        PPTextField(title: "Nickname (optional)", text: Binding(
                            get: { viewModel.draft.vehicleNickname ?? "" },
                            set: { viewModel.draft.vehicleNickname = $0 }
                        ))

                        PPFormSectionHeader(title: "Note")
                        PPTextField(title: "Notes (optional)", text: $viewModel.draft.note, axis: .vertical)

                        PPFormSectionHeader(title: "Marker")
                        MarkerStylePickerGrid(style: $viewModel.draft.markerStyle)

                        PPToggleRow(
                            title: "Favorite",
                            subtitle: "Surface this spot faster in filters and insights.",
                            isOn: $viewModel.draft.isFavorite
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(viewModel.isEditing ? "Edit Spot" : "Save Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!viewModel.isValid)
                    .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(viewModel.isValid ? 1 : 0.35))
                }
            }
            .alert("Unable to save", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveErrorMessage)
            }
            .onChange(of: viewModel.reminderEnabled) { _ in
                viewModel.applyReminderToggle(defaultOffsetMinutes: settingsStore.settings.defaultReminderOffsetMinutes)
            }
            .onChange(of: photoItem) { newValue in
                Task {
                    await loadPhoto(from: newValue)
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(height: 200)
                if let data = viewModel.draft.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Add a quick photo of signage or the aisle.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
            }
            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text(viewModel.draft.photoData == nil ? "Choose Photo" : "Replace Photo")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppPalette.primary(for: settingsStore.settings.accentTheme).opacity(0.16))
                        )
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                }
                .buttonStyle(.plain)

                if viewModel.draft.photoData != nil {
                    Button("Remove") {
                        viewModel.draft.photoData = nil
                        photoItem = nil
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                    )
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var parkingTypeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ParkingType.allCases) { type in
                    PPChip(
                        title: type.displayName,
                        isSelected: viewModel.draft.parkingType == type,
                        action: { viewModel.draft.parkingType = type }
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var timingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parked at")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            DatePicker(
                "",
                selection: $viewModel.draft.parkedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            PPToggleRow(
                title: "Parking reminder",
                subtitle: "Get a nudge before your session should end.",
                isOn: $viewModel.reminderEnabled
            )

            if viewModel.reminderEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reminder time")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    DatePicker(
                        "",
                        selection: Binding(
                            get: {
                                viewModel.draft.reminderEndTime ?? Date().addingTimeInterval(3600)
                            },
                            set: { viewModel.draft.reminderEndTime = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .tint(AppPalette.primary(for: settingsStore.settings.accentTheme))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
            }
        }
    }

    private func save() {
        let normalized = viewModel.normalizedDraft()
        if normalized.reminderEndTime != nil, normalized.reminderEndTime! <= normalized.parkedAt {
            saveErrorMessage = "Reminder time must be after the parked time."
            showSaveError = true
            return
        }

        Task {
            if normalized.reminderEndTime != nil {
                _ = await notificationService.requestAuthorizationIfNeeded()
            }
            parkingStore.upsert(normalized)
            await MainActor.run {
                dismiss()
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let jpeg = image.jpegData(compressionQuality: 0.72) {
                await MainActor.run {
                    viewModel.draft.photoData = jpeg
                }
            }
        } catch {
            await MainActor.run {
                saveErrorMessage = "We could not load that photo. Try another image."
                showSaveError = true
            }
        }
    }
}
