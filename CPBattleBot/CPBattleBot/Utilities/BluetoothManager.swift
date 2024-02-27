//
//  BluetoothManager.swift
//  CP BattleBot
//
//  Created by Kieran Valino on 2/15/24.
//

import CoreBluetooth
import Foundation

// Enum to represent connection status
enum ConnectionStatus: String {
    case connected
    case disconnected
    case searching
    case connecting
    case error
}

// UUIDs for the BLE service and characteristics
public let service_uuid: CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
public let movement_uuid: CBUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
public let rotation_uuid: CBUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
public let button_uuid: CBUUID = CBUUID(string: "6E400004-B5A3-F393-E0A9-E50E24DCCA9E")

// Peripheral name to scan for
let peripheralName = "ESP32_BLE"

// BluetoothManager class responsible for managing Bluetooth connection
class BluetoothManager: NSObject, ObservableObject
{
    // Singleton instance
    static let shared = BluetoothManager()
    
    // CBCentralManager instance for managing central role
    private var centralManager: CBCentralManager!
    
    // Currently connected peripheral
    private var espPeripheral: CBPeripheral?
    
    // Timer for reconnecting
    private var reconnectTimer: Timer?
    
    // Published variable to observe connection status
    @Published var peripheralStatus: ConnectionStatus = .disconnected
    
    // Initialize BluetoothManager
    override init() {
        super.init()
        // Initialize CBCentralManager with self as delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Start scanning for peripherals
    func scanForPeripherals() {
        peripheralStatus = .searching
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    // Send data over Bluetooth to a specific characteristic
    func sendData(_ data: String, _ charUUID: String) {
        guard let peripheral = espPeripheral else {
            print("Peripheral not connected")
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == service_uuid }) else {
            print("Service not found")
            return
        }
        
        guard let characteristic = service.characteristics?.first(where: { $0.uuid.uuidString == charUUID }) else {
            print("Characteristic not found")
            return
        }
        
        // Convert the data to Data type
        if let dataToSend = data.data(using: .utf8) {
            // Write the data to the characteristic
            peripheral.writeValue(dataToSend, for: characteristic, type: .withoutResponse)
        } else {
            print("Failed to convert data to Data type")
        }
    }
    
    // Start the timer for reconnecting
    private func startReconnectTimer() {
        // Start a timer to periodically check the connection status
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.peripheralStatus == .connected {
                // If still connected, no action needed
            } else {
                // If not connected, revert to searching
                self.peripheralStatus = .searching
                self.scanForPeripherals()
            }
        }
    }
    
    // Stop the timer for reconnecting
    private func stopReconnectTimer() {
        // Invalidate the timer when not needed
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
}

// Implement CBCentralManagerDelegate methods
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is on. Start scanning for peripherals
            print("Bluetooth On")
            scanForPeripherals()
        }
    }
    
    // Called when a peripheral is discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.hasPrefix(peripheralName) ?? false {
            print("Discovered \(peripheral.name ?? "unknown device")")
            espPeripheral = peripheral
            centralManager.connect(peripheral)
            peripheralStatus = .connecting
        }
    }
    
    // Called when a peripheral is connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected
        print("Connected to \(peripheral.name ?? "unknown device")")
        
        // Stop the reconnect timer when connected
        stopReconnectTimer()
        
        // Scan for characteristics available for us
        peripheral.delegate = self
        peripheral.discoverServices([service_uuid]) // When services discovered, notify delegate
        centralManager.stopScan()
    }
    
    // Called when a peripheral is disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .disconnected
        // Start the reconnect timer when disconnected
        startReconnectTimer()
    }
    
    // Called when a peripheral fails to connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error")
        // Start the reconnect timer when connection fails
        startReconnectTimer()
    }
}

// Implement CBPeripheralDelegate methods
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Loop through and find service we are looking for
        for service in peripheral.services ?? [] {
            if service.uuid == service_uuid {
                print("Found service for \(service_uuid)")
                peripheral.discoverCharacteristics([movement_uuid, rotation_uuid, button_uuid], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == movement_uuid {
                print("Movement Joystick characteristic discovered")
            } else if characteristic.uuid == rotation_uuid {
                print("Rotation Joystick characteristic discovered")
            } else if characteristic.uuid == button_uuid {
                print("Button characteristic discovered")
            }
        }
    }
}



//class BluetoothManager: NSObject, ObservableObject{
//    
//    private var centralManager: CBCentralManager!
//    private var espPeripheral: CBPeripheral?
//    @Published var peripheralStatus: ConnectionStatus = .disconnected
//    
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    func scanForPeripherals() {
//        peripheralStatus = .searching
//        // Scan for peripherals with service uuid
//        centralManager.scanForPeripherals(withServices: nil)
//    }
//    
//    func sendData(_ data: String, _ charUUID: String) {
//        guard let peripheral = espPeripheral else {
//            print("Peripheral not connected")
//            return
//        }
//        
//        guard let service = peripheral.services?.first(where: { $0.uuid == service_uuid }) else {
//            print("Service not found")
//            return
//        }
//        
//        guard let characteristic = service.characteristics?.first(where: { $0.uuid.uuidString == charUUID }) else {
//            print("Characteristic not found")
//            return
//        }
//        
//        // Convert the data to Data type
//        if let dataToSend = data.data(using: .utf8) {
//            // Write the data to the characteristic
//            peripheral.writeValue(dataToSend, for: characteristic, type: .withoutResponse)
//        } else {
//            print("Failed to convert data to Data type")
//        }
//    }
//
//}
//
//extension BluetoothManager: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            // Bluetooth is on. Start scanning for peripherals
//            print("Bluetooth On")
//            scanForPeripherals()
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if peripheral.name?.hasPrefix(peripheralName) ?? false {
//            print("Discovered \(peripheral.name ?? "unknown device")")
//            espPeripheral = peripheral
//            centralManager.connect(peripheral)
//            peripheralStatus = .connecting
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheralStatus = .connected
//        print("Connected to \(peripheral.name ?? "unknown device")")
//        
//        // Scan for characteristics available for us
//        peripheral.delegate = self
//        peripheral.discoverServices([service_uuid]) // When services discovered, notify delegate
//        centralManager.stopScan()
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        peripheralStatus = .disconnected
//    }
//    
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        peripheralStatus = .error
//        print(error?.localizedDescription ?? "no error")
//    }
//    
//}
//
//extension BluetoothManager: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        
//        // Loop through and find service we are looking for
//        for service in peripheral.services ?? [] 
//        {
//            if service.uuid == service_uuid 
//            {
//                print("Found service for \(service_uuid)")
//                peripheral.discoverCharacteristics([joystick_uuid, swipe_uuid, ability_uuid], for: service)
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        for characteristic in service.characteristics ?? [] {
////            peripheral.setNotifyValue(true, for: characteristic)
//            if characteristic.uuid == joystick_uuid {
//                print("Joystick characteristic discovered")
//            } else if characteristic.uuid == swipe_uuid {
//                print("Swipe characteristic discovered")
//            } else if characteristic.uuid == ability_uuid {
//                print("Ability characteristic discovered")
//            }
//        }
//    }
//    
//}
