import SwiftUI

struct PPGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: [
                AppPalette.backgroundGradientTop(for: colorScheme),
                AppPalette.backgroundGradientBottom(for: colorScheme)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
