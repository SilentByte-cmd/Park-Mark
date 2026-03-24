import SwiftUI

struct MarkerStylePickerGrid: View {
    @Binding var style: ParkingMarkerStyle

    @EnvironmentObject private var settingsStore: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ParkingMarkerCatalog.symbolOptions, id: \.self) { symbol in
                        let isSelected = style.symbolName == symbol
                        Button {
                            style = ParkingMarkerStyle(symbolName: symbol, colorIndex: style.colorIndex)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppPalette.surfaceElevated(for: colorScheme))
                                    .frame(width: 56, height: 56)
                                Image(systemName: symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(AppPalette.markerAccent(colorIndex: style.colorIndex, theme: settingsStore.settings.accentTheme))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        isSelected ? AppPalette.primary(for: settingsStore.settings.accentTheme) : AppPalette.stroke(for: colorScheme),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    let isSelected = style.colorIndex == index
                    Button {
                        style = ParkingMarkerStyle(symbolName: style.symbolName, colorIndex: index)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppPalette.markerAccent(colorIndex: index, theme: settingsStore.settings.accentTheme))
                                .frame(width: 30, height: 30)
                            if isSelected {
                                Circle()
                                    .stroke(Color.white.opacity(0.85), lineWidth: 2)
                                    .frame(width: 26, height: 26)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
