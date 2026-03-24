import Foundation

struct ParkingSpot: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var resolvedAddress: String
    var locationSource: ParkingLocationSource
    var locationLineSubtitle: String?
    var floor: String
    var zone: String
    var spotNumber: String
    var note: String
    var parkingType: ParkingType
    var parkedAt: Date
    var reminderEndTime: Date?
    var vehicleNickname: String?
    var photoData: Data?
    var isFavorite: Bool
    var markerStyle: ParkingMarkerStyle
    var isActive: Bool
    var endedAt: Date?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case address
        case latitude
        case longitude
        case resolvedAddress
        case locationSource
        case locationLineSubtitle
        case floor
        case zone
        case spotNumber
        case note
        case parkingType
        case parkedAt
        case reminderEndTime
        case vehicleNickname
        case photoData
        case isFavorite
        case markerStyle
        case isActive
        case endedAt
        case createdAt
    }

    init(
        id: UUID = UUID(),
        title: String,
        address: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        resolvedAddress: String = "",
        locationSource: ParkingLocationSource = .manual,
        locationLineSubtitle: String? = nil,
        floor: String = "",
        zone: String = "",
        spotNumber: String = "",
        note: String = "",
        parkingType: ParkingType,
        parkedAt: Date = Date(),
        reminderEndTime: Date? = nil,
        vehicleNickname: String? = nil,
        photoData: Data? = nil,
        isFavorite: Bool = false,
        markerStyle: ParkingMarkerStyle,
        isActive: Bool = true,
        endedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.resolvedAddress = resolvedAddress
        self.locationSource = locationSource
        self.locationLineSubtitle = locationLineSubtitle
        self.floor = floor
        self.zone = zone
        self.spotNumber = spotNumber
        self.note = note
        self.parkingType = parkingType
        self.parkedAt = parkedAt
        self.reminderEndTime = reminderEndTime
        self.vehicleNickname = vehicleNickname
        self.photoData = photoData
        self.isFavorite = isFavorite
        self.markerStyle = markerStyle
        self.isActive = isActive
        self.endedAt = endedAt
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        address = try c.decode(String.self, forKey: .address)
        latitude = try c.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try c.decodeIfPresent(Double.self, forKey: .longitude)
        resolvedAddress = try c.decodeIfPresent(String.self, forKey: .resolvedAddress) ?? ""
        locationSource = try c.decodeIfPresent(ParkingLocationSource.self, forKey: .locationSource) ?? .manual
        locationLineSubtitle = try c.decodeIfPresent(String.self, forKey: .locationLineSubtitle)
        floor = try c.decodeIfPresent(String.self, forKey: .floor) ?? ""
        zone = try c.decodeIfPresent(String.self, forKey: .zone) ?? ""
        spotNumber = try c.decodeIfPresent(String.self, forKey: .spotNumber) ?? ""
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
        parkingType = try c.decode(ParkingType.self, forKey: .parkingType)
        parkedAt = try c.decode(Date.self, forKey: .parkedAt)
        reminderEndTime = try c.decodeIfPresent(Date.self, forKey: .reminderEndTime)
        vehicleNickname = try c.decodeIfPresent(String.self, forKey: .vehicleNickname)
        photoData = try c.decodeIfPresent(Data.self, forKey: .photoData)
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        markerStyle = try c.decode(ParkingMarkerStyle.self, forKey: .markerStyle)
        isActive = try c.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        endedAt = try c.decodeIfPresent(Date.self, forKey: .endedAt)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(address, forKey: .address)
        try c.encodeIfPresent(latitude, forKey: .latitude)
        try c.encodeIfPresent(longitude, forKey: .longitude)
        try c.encode(resolvedAddress, forKey: .resolvedAddress)
        try c.encode(locationSource, forKey: .locationSource)
        try c.encodeIfPresent(locationLineSubtitle, forKey: .locationLineSubtitle)
        try c.encode(floor, forKey: .floor)
        try c.encode(zone, forKey: .zone)
        try c.encode(spotNumber, forKey: .spotNumber)
        try c.encode(note, forKey: .note)
        try c.encode(parkingType, forKey: .parkingType)
        try c.encode(parkedAt, forKey: .parkedAt)
        try c.encodeIfPresent(reminderEndTime, forKey: .reminderEndTime)
        try c.encodeIfPresent(vehicleNickname, forKey: .vehicleNickname)
        try c.encodeIfPresent(photoData, forKey: .photoData)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(markerStyle, forKey: .markerStyle)
        try c.encode(isActive, forKey: .isActive)
        try c.encodeIfPresent(endedAt, forKey: .endedAt)
        try c.encode(createdAt, forKey: .createdAt)
    }
}
