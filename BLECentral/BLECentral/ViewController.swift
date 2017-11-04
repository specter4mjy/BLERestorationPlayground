//
//  ViewController.swift
//  BLECentral
//
//  Created by john on 11/3/17.
//  Copyright © 2017 john. All rights reserved.
//

import UIKit
import CoreBluetooth

struct BLEConstant{
    static let serviceUUID = CBUUID(string: "CD5F2B78-682D-4FC5-8BE0-4E0826CCCA5F")
    static let characteristicUUID = CBUUID(string: "6119467C-9549-461A-A8DD-F73427FEC227")
}

class ViewController: UIViewController {
    lazy var centralManager = {
        return CBCentralManager(delegate: self, queue: nil)
    }()
    
    var peripherals : Set<CBPeripheral> = []
    var characteristic : CBCharacteristic?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = centralManager
        
    }
    
    @IBAction func fetchItHandler() {
        if let peripheral = peripherals.first {
            switch peripheral.state{
            case .connected:
                peripherals.first?.readValue(for: characteristic!)
            case .disconnected:
                centralManager.connect(peripheral, options: nil)
            default:
                break
            }
        }
    }
    
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.centralManager.scanForPeripherals(withServices: [BLEConstant.serviceUUID], options: nil)
        default:
            // TODO: handle the reset states
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discoveredPeripheral: \(peripheral)")

        peripherals.insert(peripheral)
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected: \(peripheral)")
        
        peripheral.delegate = self
        peripheral.discoverServices([BLEConstant.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected: \(peripheral)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.centralManager.connect(peripheral, options: nil)
        }
    }
}

extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discoverServices: \(peripheral)")
        
        if let error = error {
            print("discoverServicesError: \(error)")
            return
        }

        peripheral.services?.forEach{ service in
            peripheral.discoverCharacteristics([BLEConstant.characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("ModifyServices: \(invalidatedServices)")
        if invalidatedServices.count > 0 {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discoverCharacteristics: \(peripheral)")
        
        if let error = error {
            print("discoverCharacteristicsError: \(error)")
            return
        }

        service.characteristics?.forEach{ characteristic in
            
            // FIXME: dirty code
            self.characteristic = characteristic
            
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("updateValueError: \(error)")
            if error.localizedDescription == "The attribute could not be found." {
                centralManager.cancelPeripheralConnection(peripheral)
            }
            return
        }

        if let value = characteristic.value {
            if let valueString = String(data: value, encoding: .utf8) {
                print("data is \(valueString)")
            }
        }
    }
    
}
