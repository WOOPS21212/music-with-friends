
// BluetoothManager.swift - For discovering nearby users
import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    // Published properties for UI updates
    @Published var discoveredUsers: [String: UserDiscoveryInfo] = [:]
    @Published var isScanning: Bool = false
    @Published var nearbySessionIDs: [String] = []
    @Published var bluetoothState: BluetoothState = .unknown
    
    // Bluetooth managers
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    
    // Service and characteristic UUIDs
    private let serviceUUID = CBUUID(string: "A1B2C3D4-E5F6-47A8-B9C0-D1E2F3A4B5C6")
    private let userCharacteristicUUID = CBUUID(string: "BCD12345-6789-0ABC-DEF1-23456789ABCD")
    private let sessionCharacteristicUUID = CBUUID(string: "CDE23456-789A-BCDE-F123-456789ABCDEF")
    
    // User information to advertise
    private var currentUserID: String?
    private var currentSessionID: String?
    
    // Timer for cleaning up old discoveries
    private var cleanupTimer: Timer?
    
    // Initialization
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Start cleanup timer
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.cleanupOldDiscoveries()
        }
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        isScanning = true
        centralManager.scanForPeripherals(
            withServices: [serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func startAdvertising(userID: String, sessionID: String? = nil) {
        guard bluetoothState == .poweredOn else { return }
        
        self.currentUserID = userID
        self.currentSessionID = sessionID
        
        // Create service and characteristics
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // User characteristic
        let userCharacteristic = CBMutableCharacteristic(
            type: userCharacteristicUUID,
            properties: .read,
            value: userID.data(using: .utf8),
            permissions: .readable
        )
        
        // Session characteristic (if available)
        var characteristics: [CBCharacteristic] = [userCharacteristic]
        
        if let sessionID = sessionID {
            let sessionCharacteristic = CBMutableCharacteristic(
                type: sessionCharacteristicUUID,
                properties: .read,
                value: sessionID.data(using: .utf8),
                permissions: .readable
            )
            characteristics.append(sessionCharacteristic)
        }
        
        service.characteristics = characteristics
        
        // Add service to peripheral manager
        peripheralManager.removeAllServices()
        peripheralManager.add(service)
        
        // Start advertising
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: UIDevice.current.name
        ])
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        currentUserID = nil
        currentSessionID = nil
    }
    
    // MARK: - Private Methods
    
    private func cleanupOldDiscoveries() {
        let cutoffDate = Date().addingTimeInterval(-60) // Remove anything not seen in the last minute
        
        discoveredUsers = discoveredUsers.filter { $0.value.lastSeen > cutoffDate }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothState = .poweredOn
            if isScanning {
                startScanning()
            }
        case .poweredOff:
            bluetoothState = .poweredOff
            isScanning = false
        case .resetting:
            bluetoothState = .resetting
        case .unauthorized:
            bluetoothState = .unauthorized
        case .unsupported:
            bluetoothState = .unsupported
        case .unknown:
            bluetoothState = .unknown
        @unknown default:
            bluetoothState = .unknown
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Extract device name
        let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Unknown Device"
        
        // Create or update user discovery info
        let deviceID = peripheral.identifier.uuidString
        
        // Store initial discovery
        var discoveryInfo = discoveredUsers[deviceID] ?? UserDiscoveryInfo(
            deviceID: deviceID,
            deviceName: deviceName,
            userID: nil,
            sessionID: nil,
            rssi: RSSI.intValue,
            lastSeen: Date()
        )
        
        // Update last seen and signal strength
        discoveryInfo.lastSeen = Date()
        discoveryInfo.rssi = RSSI.intValue
        
        // Update in our dictionary
        discoveredUsers[deviceID] = discoveryInfo
        
        // Connect to peripheral to get more details
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Discover services
        peripheral.discoverServices([serviceUUID])
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        
        // Discover characteristics for each service
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(
                [userCharacteristicUUID, sessionCharacteristicUUID],
                for: service
            )
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        
        let deviceID = peripheral.identifier.uuidString
        var discoveryInfo = discoveredUsers[deviceID]
        
        // Read characteristics
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == userCharacteristicUUID {
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == sessionCharacteristicUUID {
                peripheral.readValue(for: characteristic)
            }
        }
        
        // Update discovery info
        if let discoveryInfo = discoveryInfo {
            discoveredUsers[deviceID] = discoveryInfo
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        
        let deviceID = peripheral.identifier.uuidString
        var discoveryInfo = discoveredUsers[deviceID]
        
        if characteristic.uuid == userCharacteristicUUID, let userID = String(data: data, encoding: .utf8) {
            discoveryInfo?.userID = userID
        } else if characteristic.uuid == sessionCharacteristicUUID, let sessionID = String(data: data, encoding: .utf8) {
            discoveryInfo?.sessionID = sessionID
            
            // Add to nearby sessions if not already there
            if let sessionID = sessionID, !nearbySessionIDs.contains(sessionID) {
                nearbySessionIDs.append(sessionID)
            }
        }
        
        // Update discovery info
        if let discoveryInfo = discoveryInfo {
            discoveredUsers[deviceID] = discoveryInfo
        }
        
        // Disconnect once we have the information
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

// MARK: - CBPeripheralManagerDelegate

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            bluetoothState = .poweredOn
            if let userID = currentUserID {
                startAdvertising(userID: userID, sessionID: currentSessionID)
            }
        case .poweredOff:
            bluetoothState = .poweredOff
        case .resetting:
            bluetoothState = .resetting
        case .unauthorized:
            bluetoothState = .unauthorized
        case .unsupported:
            bluetoothState = .unsupported
        case .unknown:
            bluetoothState = .unknown
        @unknown default:
            bluetoothState = .unknown
        }
    }
}

// Bluetooth state enum
enum BluetoothState {
    case poweredOn
    case poweredOff
    case resetting
    case unauthorized
    case unsupported
    case unknown
}

