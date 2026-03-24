import SwiftUI

struct HistoryFilterSheet: View {
    @Binding var selection: HistoryFilterMode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        NavigationStack {
            ZStack {
                PPGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(HistoryFilterMode.allCases) { mode in
                            Button {
                                selection = mode
                                dismiss()
                            } label: {
                                HStack {
                                    Text(mode.displayName)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selection == mode {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppPalette.primary(for: settingsStore.settings.accentTheme))
                }
            }
        }
    }
}
