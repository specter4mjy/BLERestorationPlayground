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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = centralManager
        
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
        peripherals.insert(peripheral)
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([BLEConstant.serviceUUID])
    }
}

extension ViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach{ service in
            peripheral.discoverCharacteristics([BLEConstant.characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach{ characteristic in
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            if let valueString = String(data: value, encoding: .utf8) {
                print("data is \(valueString)")
            }
        }
    }
    
}
