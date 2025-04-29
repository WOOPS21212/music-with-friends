import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    @Published var discoveredUsers: [String] = []
    @Published var isScanning = false
    
    // For demonstration purposes only
    func startScanning() {
        isScanning = true
        
        // Simulate finding users nearby
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.discoveredUsers = [
                "John's iPhone",
                "Sarah's iPhone",
                "Music Party"
            ]
        }
    }
    
    func stopScanning() {
        isScanning = false
    }
}
