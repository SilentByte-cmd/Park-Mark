import SwiftUI

struct PPTextField: View {
    let title: String
    @Binding var text: String
    var axis: Axis = .horizontal

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("", text: $text, axis: axis)
                .textInputAutocapitalization(.sentences)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppPalette.surfaceElevated(for: colorScheme))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppPalette.stroke(for: colorScheme), lineWidth: 1)
                )
        }
    }
}
