// User.swift
import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var profilePicture: URL?
    var connectedServices: [MusicService: String] // Service ID mappings
    var topArtists: [String]?
    var favoriteGenres: [String]?
    var deviceID: String // For Bluetooth/proximity identification
    var lastActive: Date
    
    // For simplified serialization of dictionary
    enum CodingKeys: String, CodingKey {
        case id, name, profilePicture, topArtists, favoriteGenres, deviceID, lastActive
        case connectedServicesRaw = "connectedServices"
    }
    
    init(id: String, name: String, profilePicture: URL? = nil,
         connectedServices: [MusicService: String] = [:],
         topArtists: [String]? = nil, favoriteGenres: [String]? = nil,
         deviceID: String, lastActive: Date = Date()) {
        self.id = id
        self.name = name
        self.profilePicture = profilePicture
        self.connectedServices = connectedServices
        self.topArtists = topArtists
        self.favoriteGenres = favoriteGenres
        self.deviceID = deviceID
        self.lastActive = lastActive
    }
    
    // Custom encoding for the dictionary
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(profilePicture, forKey: .profilePicture)
        try container.encode(topArtists, forKey: .topArtists)
        try container.encode(favoriteGenres, forKey: .favoriteGenres)
        try container.encode(deviceID, forKey: .deviceID)
        try container.encode(lastActive, forKey: .lastActive)
        
        // Convert dictionary to array of key-value pairs
        let servicesArray = connectedServices.map {
            ["service": $0.key.rawValue, "id": $0.value]
        }
        try container.encode(servicesArray, forKey: .connectedServicesRaw)
    }
    
    // Custom decoding for the dictionary
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profilePicture = try container.decodeIfPresent(URL.self, forKey: .profilePicture)
        topArtists = try container.decodeIfPresent([String].self, forKey: .topArtists)
        favoriteGenres = try container.decodeIfPresent([String].self, forKey: .favoriteGenres)
        deviceID = try container.decode(String.self, forKey: .deviceID)
        lastActive = try container.decode(Date.self, forKey: .lastActive)
        
        // Reconstruct dictionary from array
        let servicesArray = try container.decode([[String: String]].self, forKey: .connectedServicesRaw)
        connectedServices = [:]
        for item in servicesArray {
            if let serviceRaw = item["service"], let serviceID = item["id"],
               let service = MusicService(rawValue: serviceRaw) {
                connectedServices[service] = serviceID
            }
        }
    }
}
