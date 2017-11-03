//
//  ViewController.swift
//  BLEPeripheral
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
    lazy var peripheralManager = {
        return CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }()
    
    let characteristic = CBMutableCharacteristic(type: BLEConstant.characteristicUUID, properties: .read, value: nil, permissions: .readable)
    lazy var service: CBMutableService = {
        let service = CBMutableService(type: BLEConstant.serviceUUID, primary: true)
        service.characteristics = [self.characteristic]
        return service
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _ = peripheralManager
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            peripheralManager.add(service)
        default:
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLEConstant.serviceUUID]])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        print("start advertising...")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        request.value = "tset".data(using: .utf8)
        peripheral.respond(to: request, withResult: .success)
    }
    
    
}

