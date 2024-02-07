//
//  BluetoothManager.swift
//  BattleBotJoySticks
//
//  Created by Aaron Rosen on 11/8/23.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Declare the ESP32 device name pattern
//    private let esp32DevicePrefix = "ESP32"
    private let esp32DeviceName = "ESP32_BLE"
    
    // Dictionary to store discovered characteristics by UUID
    var characteristicDict: [String: [CBCharacteristic]] = [:]
    
    // 3 Bluetooth characteristic UUIDs
    public let service_uuid = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let joystick_uuid = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let swipe_uuid = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let ability_uuid = CBUUID(string: "6E400004-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let rotation_uuid = CBUUID(string: "6E400005-B5A3-F393-E0A9-E50E24DCCA9E")
    
    
    @Published var peripheral: CBPeripheral?
    var centralManager: CBCentralManager!

    // Singleton instance
    public static let shared = BluetoothManager()

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Implement CBCentralManagerDelegate methods

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is powered on, start scanning for peripherals
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // Handle other states, such as .poweredOff, .resetting, .unauthorized, etc.
            print("Bluetooth is not available.")
        }
    }
    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
//                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        // Check if the discovered peripheral name starts with "ESP32"
//        if peripheral.name?.hasPrefix(esp32DevicePrefix) ?? false {
//            // Stop scanning once the peripheral is found
//            centralManager.stopScan()
//
//            // Save the reference to the peripheral
//            self.peripheral = peripheral
//
//            // Connect to the peripheral
//            centralManager.connect(peripheral, options: nil)
//        }
//    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the discovered peripheral is your ESP32
        print("searching")
        if peripheral.name == esp32DeviceName {
            print("found")
            // Stop scanning once the peripheral is found
            centralManager.stopScan()

            // Save the reference to the peripheral
            self.peripheral = peripheral

            // Connect to the peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Peripheral connected, you can now start interacting with it
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // Add this method to your BluetoothManager class
    func sendData(_ data: String, _ charUUID: String) {
        guard let peripheral = peripheral else {
            print("No peripheral available.")
            return
        }

        // Check if the peripheral is connected
        guard peripheral.state == .connected else {
            print("Peripheral is not connected.")
            return
        }

        // Assume you want to send the data as UTF-8 encoded data
        if let dataToSend = data.data(using: .utf8) {
            // Replace "yourCharacteristicUUID" with the actual UUID of the characteristic you want to write to
            guard let characteristic = findCharacteristic(withUUID: charUUID, in: peripheral) else {
                print("Characteristic not found.")
                return
            }

            // Write the data to the characteristic
            peripheral.writeValue(dataToSend, for: characteristic, type: .withoutResponse)
        } else {
            print("Failed to encode data.")
        }
    }
    
    // Helper method to find a characteristic by UUID
    private func findCharacteristic(withUUID uuid: String, in peripheral: CBPeripheral) -> CBCharacteristic? {
        print("looking")
        guard let characteristics = characteristicDict[uuid] else { return nil }
        // You might want to add logic here to choose a characteristic if there are multiple instances with the same UUID.
        return characteristics.first // Returning the first one for simplicity
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        if let services = peripheral.services {
            for service in services {
                // Discover characteristics for each service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }

        if let characteristics = service.characteristics {
            // Store the discovered characteristics in the dictionary
            for characteristic in characteristics {
                let uuidString = characteristic.uuid.uuidString
                if characteristicDict[uuidString] == nil {
                    characteristicDict[uuidString] = [characteristic]
                } else {
                    characteristicDict[uuidString]?.append(characteristic)
                }

                // Do something with the discovered characteristics if needed
                print("Discovered characteristic: \(characteristic)")
            }
        }
    }
    
    // Deinitializer to clean up resources if needed
    deinit {
        centralManager.delegate = nil
        peripheral?.delegate = nil
    }
}
