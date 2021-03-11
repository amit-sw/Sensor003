//
//  Aranet4Manager.swift
//  Sensor003
//
//  Created by Amit Gupta on 3/2/21.
//

import UIKit
import CoreBluetooth
//import Firebase
//import FirebaseFirestore

class Aranet4Manager: NSObject {
    
    var centralManager: CBCentralManager!
    var co2Peripheral: CBPeripheral!
    var writeCharacteristic : CBCharacteristic!
    
    var sleepTime : UInt32 = 300
    var use1503 = false
    var use3001 = true
    
    /*
     From https://github.com/Anrijs/Aranet4-Python/blob/master/aranet4/client.py
     
      AR4_SERVICE                   = btle.UUID("f0cd1400-95da-4f4b-9ac8-aa55d312af0c") // This is the main Service Aranet4 provides
     
      GENERIC_SERVICE               = btle.UUID("00001800-0000-1000-8000-00805f9b34fb")
      COMMON_SERVICE                = btle.UUID("0000180a-0000-1000-8000-00805f9b34fb")

      # Read / Aranet service
      AR4_READ_CURRENT_READINGS     = btle.UUID("f0cd1503-95da-4f4b-9ac8-aa55d312af0c")
      AR4_READ_CURRENT_READINGS_DET = btle.UUID("f0cd3001-95da-4f4b-9ac8-aa55d312af0c") // This is the main reading service we use
      AR4_READ_INTERVAL             = btle.UUID("f0cd2002-95da-4f4b-9ac8-aa55d312af0c")
      AR4_READ_SECONDS_SINCE_UPDATE = btle.UUID("f0cd2004-95da-4f4b-9ac8-aa55d312af0c")
      AR4_READ_TOTAL_READINGS       = btle.UUID("f0cd2001-95da-4f4b-9ac8-aa55d312af0c")

      # Read / Generic servce
      GENERIC_READ_DEVICE_NAME       = btle.UUID("00002a00-0000-1000-8000-00805f9b34fb")

      # Read / Common servce
      COMMON_READ_MANUFACTURER_NAME = btle.UUID("00002a29-0000-1000-8000-00805f9b34fb")
      COMMON_READ_MODEL_NUMBER      = btle.UUID("00002a24-0000-1000-8000-00805f9b34fb")
      COMMON_READ_SERIAL_NO         = btle.UUID("00002a25-0000-1000-8000-00805f9b34fb")
      COMMON_READ_HW_REV            = btle.UUID("00002a27-0000-1000-8000-00805f9b34fb")
      COMMON_READ_SW_REV            = btle.UUID("00002a28-0000-1000-8000-00805f9b34fb")
      COMMON_READ_BATTERY           = btle.UUID("00002a19-0000-1000-8000-00805f9b34fb")

      # Write / Aranet service
      AR4_WRITE_CMD= btle.UUID("f0cd1402-95da-4f4b-9ac8-aa55d312af0c")

      # Subscribe / Aranet service
      AR4_SUBSCRIBE_HISTORY         = 0x0032
      AR4_NOTIFY_HISTORY            = 0x0031
     */
    
    let ARANET4SERVICE_UUID="F0CD1400-95DA-4F4B-9AC8-AA55D312AF0C"
    let ARANET4READING_UUID="F0CD3001-95DA-4F4B-9AC8-AA55D312AF0C"
    let ARANET4WRITE_UUID="f0cd1402-95da-4f4b-9ac8-aa55d312af0c".uppercased()
    
    
    var restoreIdKey="Aranet4Restore"
    static var mainText=""
    
    //@IBOutlet weak var topLabel: UILabel!
    //@IBOutlet weak var mainText: UILabel!
    //@IBOutlet weak var lowerLabel: UILabel!
    
    
    
    func initializeAranet4() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:restoreIdKey])
    }
    
}

extension Aranet4Manager: CBCentralManagerDelegate {
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
            //centralManager.scanForPeripherals(withServices: nil)
            //centralManager.scanForPeripherals(withServices: [CBUUID(string: "03E6832A-7697-E5A8-641E-E617AA95033D")])
            centralManager.scanForPeripherals(withServices: [CBUUID(string: ARANET4SERVICE_UUID)])
            
        @unknown default:
            print("central.state is unknown: ",central.self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Peripheral:",peripheral)
        if((peripheral.name?.starts(with: "Aranet")) == true) {
            print("Found Aranet device:",peripheral)
            co2Peripheral = peripheral
            co2Peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(co2Peripheral)
        }
        //print("Finished processing device")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        co2Peripheral.discoverServices([CBUUID(string: ARANET4SERVICE_UUID)])
        print("Finished discovery")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //let restoredPeripherals=dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]
        print("Central Manager: Will Restore Start")
        //centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:restoreIdKey])
        print("Central Manager: Will Restore End")
    }
    
}

extension Aranet4Manager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service: ",service)
            if(service.uuid.uuidString.starts(with: "F0CD1400")) {
                peripheral.discoverCharacteristics([CBUUID(string: ARANET4READING_UUID)], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Characteristic: ",characteristic)
            
            if characteristic.properties.contains(.read) {
                //print("Char read \(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                //print("Char notify \(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid.uuidString.starts(with: ARANET4WRITE_UUID) {
               writeCharacteristic=characteristic
                print("Saw Write Chacteristic:",writeCharacteristic ?? "<Not found>")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        guard let characteristicData = characteristic.value else {print("Null characteristic data"); return}
        let byteArray = [UInt8](characteristicData)
        //print(byteArray)
        if(characteristic.uuid.uuidString.starts(with: "F0CD3001")) {
            if(use3001) {
                handleF0CD3001(byteArray: byteArray)
                peripheral.setNotifyValue(true, for: characteristic)
                let s2 = String(format:"use3001: Update in %d secs",sleepTime)
                print(s2)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+Double(sleepTime)) {
                    print("use3001: On the road again...")
                    self.centralManager.connect(self.co2Peripheral)
                    //self.lowerLabel.text = "Fetching..."
                }
 
            }
            
        }
        if(characteristic.uuid.uuidString.starts(with: "F0CD1503")) {
            if(use1503) {
                handleF0CD1503(byteArray: byteArray)
                //peripheral.setNotifyValue(true, for: characteristic)
                let s2 = String(format:"use1503: Update in %d secs",sleepTime)
                print(s2)
                DispatchQueue.main.asyncAfter(deadline: .now()+Double(sleepTime)) {
                    print("use1503: On the road again...")
                    self.centralManager.connect(self.co2Peripheral)
                    //self.lowerLabel.text = "Fetching..."
                }
            }
        }
        
        //print("Finished printing")
        //Unhandled Characteristic UUID: F0CD3001-95DA-4F4B-9AC8-AA55D312AF0C
        // [141, 1, 195, 1, 97, 39, 34, 90, 1, 44, 1, 171, 0]
    }
    
    func baToInt(_ b1:UInt8,_ b2:UInt8) ->Int {
        let i1=Int(b1)
        let i2=Int(b2)
        let i = i1+256*i2
        return i
    }
    
    func getCurrentDateTime() -> String {
        let currentDateTime=Date()
        let formatter=DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let dateTimeStr=formatter.string(from: currentDateTime)
        return dateTimeStr
    }
    
    func handleF0CD3001(byteArray: [UInt8]) {
        //print("F0CD3001 shows byte array:",byteArray)
        let c = baToInt(byteArray[0],byteArray[1])
        let t1 = baToInt(byteArray[2],byteArray[3])
        let t2 = Float(t1)/20
        let t = (t2*9/5) + 32
        // let t3 = (t2-32)*5/9
        let p = (baToInt(byteArray[4],byteArray[5]) )/10
        let h = baToInt(byteArray[6],0)
        let b = baToInt(byteArray[7],0)
        let i = baToInt(byteArray[9],byteArray[10])
        let a = baToInt(byteArray[11],byteArray[12])
        sleepTime=UInt32(i-a)
        let cdt = getCurrentDateTime()
        print(getCurrentDateTime(),": 3001 Seeing values: ",c,t,p,h,b,i,a, "with t1 & t2 as",t1,t2)
        let s = String(format:"As of \(cdt)\nCO2 %d ppm\n Temp %.1f F\nPressure %d mbar\nHumidity %d%%\nBattery %d%%",c,t,p,h,b)
        Aranet4Manager.mainText = s
        GoogleSheetsIntegration.recordSensor(source:"Aranet4",co2:c,timestamp:cdt, tempF:t, pressure:p, humidity:h,battery:b)
        
    }
    
    func handleF0CD1503(byteArray: [UInt8]) {
        //print("F0CD1503 shows byte array:",byteArray)
        let c = baToInt(byteArray[0],byteArray[1])
        let t1 = baToInt(byteArray[2],byteArray[3])
        let t2 = Float(t1)/20
        let t = (t2*9/5) + 32
        let p = (baToInt(byteArray[4],byteArray[5]) )/10
        let h = baToInt(byteArray[6],0)
        let b = baToInt(byteArray[7],0)
        //let i = baToInt(byteArray[9],byteArray[10])
        //let a = baToInt(byteArray[11],byteArray[12])
        print(getCurrentDateTime(),": 1503 Seeing values: ",c,t,p,h,b, "with t1 & t2 as",t1,t2)
        GoogleSheetsIntegration.recordSensor(source:"Aranet4",co2:c,timestamp:"Not known 1503", tempF:t, pressure:p, humidity:h,battery:b)
    }
    
    func updateAranet4Interval(_ newInterval: Int) {
        var bArray:[UInt8]=[0x9,0x0,0x0,0x0]
        switch(newInterval) {
        case 1: bArray[3]=0x1;
            break;
        case 2: bArray[3]=0x2;
            break;
        case 5: bArray[3]=0x5;
            break;
        case 10: bArray[3]=0xA;
            break;
        default:
            print("Error. Interval",newInterval," is not 1,2,5, or 10. **** NO CHANGES *****")
        }
        print("Starting: Write byte array characteristic",bArray)
        print("TO-DO TO-DO TO-DO: Write byte array characteristic",bArray)
        co2Peripheral.writeValue(Data(bArray), for: writeCharacteristic, type: .withResponse)
        print("Finished: Write byte array characteristic",bArray)
    }
    
    func updateValues() {
        print("Updating values")
    }
    
    func updateStatus(s:String) {
        print("Setting status s =",s)
    }
    
}
