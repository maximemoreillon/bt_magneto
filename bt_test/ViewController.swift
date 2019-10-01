//
//  ViewController.swift
//  bt_test
//
//  Created by Maxime Moreillon on 2019/09/06.
//  Copyright © 2019 kitec. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController{
    
    
    var centralManager: CBCentralManager!
    
    var witMotionPeripheral: CBPeripheral!
    
    var identifier : UUID = UUID(uuidString: "712AC0BA-31C6-AE93-EED2-22390D7730EB")!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("didload")
        
        centralManager = CBCentralManager(delegate: self, queue: nil)


    }


}

extension ViewController: CBCentralManagerDelegate {
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        }

    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if(peripheral.identifier == identifier){
            print("found")
            witMotionPeripheral = peripheral
            witMotionPeripheral.delegate = self

            
            centralManager.stopScan()
            centralManager.connect(witMotionPeripheral)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        witMotionPeripheral.discoverServices(nil)
    }
    
    
}


extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            //print(service)
            peripheral.discoverCharacteristics(nil, for: service)


        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            //print(characteristic)
            if characteristic.properties.contains(.read) {
                //print("\(characteristic.uuid): properties contains .read")
                print("Property contains .READ")
                peripheral.readValue(for: characteristic)

            }
            if characteristic.properties.contains(.notify) {
                //print("\(characteristic.uuid): properties contains .notify")
                print("Property contains .NOTIFY")
                peripheral.setNotifyValue(true, for: characteristic)

            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        let payloadBytes = [UInt8](characteristic.value!)
        
        let YawBytesStartIndex = 18
        let YawL:Int = Int(payloadBytes[YawBytesStartIndex])
        let YawH:Int = Int(payloadBytes[YawBytesStartIndex + 1])
        
        var Yaw=Float((YawH<<8)|YawL)
        Yaw = Yaw/32768.00*180.00
        
        print(Yaw)
        

        
    }
}
