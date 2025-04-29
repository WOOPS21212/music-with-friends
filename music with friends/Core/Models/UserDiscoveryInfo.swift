//
//  UserDiscoveryInfo.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//


// UserDiscoveryInfo.swift - For proximity detection
import Foundation

struct UserDiscoveryInfo: Identifiable, Codable {
    var id: String { deviceID }
    var deviceID: String
    var deviceName: String
    var userID: String?
    var sessionID: String?
    var rssi: Int // Signal strength
    var lastSeen: Date
    
    var signalStrength: Int {
        // Convert RSSI to a more user-friendly 0-5 scale
        // RSSI usually ranges from about -30 (very close) to -90 (far)
        if rssi >= -35 { return 5 }
        if rssi >= -50 { return 4 }
        if rssi >= -65 { return 3 }
        if rssi >= -80 { return 2 }
        return 1
    }
}
