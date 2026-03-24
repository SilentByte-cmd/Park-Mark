import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var parkingStore: ParkingSpotStore
    @EnvironmentObject private var settingsStore: AppSettingsStore
    @EnvironmentObject private var onboardingStore: OnboardingStore

    @StateObject private var viewModel = SettingsViewModel()

    @State private var showClearHistoryConfirmation = false
    @State private var showResetOnboardingConfirmation = false

    var body: some View {
        ZStack {
            PPGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.largeTitle.weight(.bold))
                    Text("Tune Park Pin to match your routines.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    PPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Accent preview")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 10) {
                                ForEach(AppAccentTheme.allCases) { theme in
                                    Button {
                                        settingsStore.updateAccent(theme)
                                    } label: {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(AppPalette.primary(for: theme))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(settingsStore.settings.accentTheme == theme ? 0.9 : 0), lineWidth: 2)
                                                )
                                            Text(theme.displayName)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    PPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            PPFormSectionHeader(title: "Defaults")
                            Text("Default parking type")
                                .font(.subheadline.weight(.semibold))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ParkingType.allCases) { type in
                                        PPChip(
                                            title: type.displayName,
                                            isSelected: settingsStore.settings.defaultParkingType == type,
                                            action: { settingsStore.updateDefaultParkingType(type) }
                                        )
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)

                            Divider().opacity(0.25)

                            PPToggleRow(
                                title: "Default reminder",
                                subtitle: "New sessions start with a reminder when enabled.",
                                isOn: Binding(
                                    get: { settingsStore.settings.defaultReminderEnabled },
                                    set: { settingsStore.updateDefaultReminderEnabled($0) }
                                )
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Default reminder offset")
                                    .font(.subheadline.weight(.semibold))
                                Text(viewModel.formattedReminderOffset(minutes: settingsStore.settings.defaultReminderOffsetMinutes))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 12) {
                                    stepButton(title: "- 15m") {
                                        settingsStore.updateDefaultReminderOffset(minutes: settingsStore.settings.defaultReminderOffsetMinutes - 15)
                                    }
                                    stepButton(title: "+ 15m") {
                                        settingsStore.updateDefaultReminderOffset(minutes: settingsStore.settings.defaultReminderOffsetMinutes + 15)
                                    }
                                    stepButton(title: "+ 1h") {
                                        settingsStore.updateDefaultReminderOffset(minutes: settingsStore.settings.defaultReminderOffsetMinutes + 60)
                                    }
                                }
                            }
                        }
                    }

                    PPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            PPFormSectionHeader(title: "Data")
                            PPSecondaryButton(title: "Clear all history", isEnabled: !parkingStore.spots.isEmpty) {
                                showClearHistoryConfirmation = true
                            }
                            Text("Removes every saved parking record and pending reminders on this device.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    PPCard {
                        VStack(alignment: .leading, spacing: 12) {
                            PPFormSectionHeader(title: "Experience")
                            PPSecondaryButton(title: "Replay onboarding", isEnabled: true) {
                                showResetOnboardingConfirmation = true
                            }
                            Text("Shows the welcome flow again on next launch.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    PPCard {
                        VStack(alignment: .leading, spacing: 8) {
                            PPFormSectionHeader(title: "About")
                            Text("Park Pin")
                                .font(.headline.weight(.bold))
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Built for calm, offline-first parking recall.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear all history?", isPresented: $showClearHistoryConfirmation) {
            Button("Clear everything", role: .destructive) {
                parkingStore.deleteAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every parking record and cannot be undone.")
        }
        .alert("Replay onboarding?", isPresented: $showResetOnboardingConfirmation) {
            Button("Reset", role: .destructive) {
                onboardingStore.resetOnboarding()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will see the welcome flow again next time you open the app.")
        }
    }

    private func stepButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.secondary.opacity(0.12))
                )
                .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
        }
        .buttonStyle(.plain)
    }
}
