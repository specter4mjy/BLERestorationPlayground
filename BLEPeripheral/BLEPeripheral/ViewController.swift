//
//  ViewController.swift
//  BLEPeripheral
//
//  Created by john on 11/3/17.
//  Copyright © 2017 john. All rights reserved.
//

import UIKit
import CoreBluetooth
import os.log

struct BLEConstant{
    static let serviceUUID = CBUUID(string: "CD5F2B78-682D-4FC5-8BE0-4E0826CCCA5F")
    static let characteristicUUID = CBUUID(string: "6119467C-9549-461A-A8DD-F73427FEC227")
    static let peripheralRestorationID = "peripheralRestorationID"
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func creshItHandler() {
        kill(getpid(), SIGKILL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class PeripheralManager {
    static var shared =
        CBPeripheralManager(delegate: PeripheralManagerDelegate.shared, queue: nil, options: [CBPeripheralManagerOptionRestoreIdentifierKey: BLEConstant.peripheralRestorationID])
    
}

class PeripheralManagerDelegate : NSObject{
    static var shared = PeripheralManagerDelegate()
    
    var service: CBMutableService = {
        let characteristic = CBMutableCharacteristic(type: BLEConstant.characteristicUUID, properties: .read, value: nil, permissions: .readable)
        let service = CBMutableService(type: BLEConstant.serviceUUID, primary: true)
        service.characteristics = [characteristic]
        return service
    }()
    
}

extension PeripheralManagerDelegate: CBPeripheralManagerDelegate {
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        
        print("will restore")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
                print("stop advertising...")
            }
            
            
            // TODO: may this can be improved
            print("remove advertising...")
            peripheral.removeAllServices()
            peripheral.add(service)
            
        default:
            peripheral.stopAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {

        if let error = error {
            print("didAddService: \(error)")
            return
        }
        
        print("add service...")
        
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLEConstant.serviceUUID]])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("didStartAdvertising: \(error)")
            return
        }
        print("start advertising...")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("receive read request...")

        request.value = Date().description.data(using: .utf8)
        peripheral.respond(to: request, withResult: .success)
    }
    
    
}

