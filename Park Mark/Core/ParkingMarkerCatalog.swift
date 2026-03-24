import Foundation

enum ParkingMarkerCatalog {
    static let defaultStyle = ParkingMarkerStyle(symbolName: "parkingsign.circle.fill", colorIndex: 0)

    static let symbolOptions: [String] = [
        "parkingsign.circle.fill",
        "car.circle.fill",
        "mappin.circle.fill",
        "flag.circle.fill",
        "star.circle.fill",
        "bolt.circle.fill",
        "leaf.circle.fill",
        "building.2.crop.circle.fill"
    ]
}
