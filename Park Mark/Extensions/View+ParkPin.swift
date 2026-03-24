import SwiftUI

extension View {
    func parkPinCardShadow() -> some View {
        shadow(color: Color.black.opacity(0.10), radius: 18, x: 0, y: 10)
    }

    func parkPinSoftShadow() -> some View {
        shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}
