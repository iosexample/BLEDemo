//
//  OperationViewController.swift
//  BLEDemo
//
//  Created by dong on 7/3/2018.
//  Copyright © 2018 dong. All rights reserved.
//

import UIKit
import CoreBluetooth

class OperationViewController: UIViewController {
    var characteristic: CBCharacteristic?
    
    enum ValueFormat: Int {
        case hex, bin, string
    }
    var valueFormat = ValueFormat.hex
    
    @IBOutlet weak var readValueField: UITextField!
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let periperal = characteristic?.service.peripheral {
            periperal.delegate = self
            
            if characteristic!.properties.contains(.read) {
                periperal.readValue(for: characteristic!)
            }
            else {
                readValueField.text = "Not Support"
            }
            
            sendButton.isEnabled = characteristic!.properties.contains(.write)
            sendTextView.isEditable = sendButton.isEnabled
            if !sendButton.isEnabled {
                sendTextView.text = "Not Support"
            }
            
            notifySwitch.isEnabled = characteristic!.properties.contains(.notify)
        }
    }

    func updateReadValueField() {
        guard let data = characteristic?.value else {
            readValueField.text = ""
            return
        }
        
        var text: String
        switch valueFormat {
        case .bin:
//            let characterSet = CharacterSet(charactersIn: "<>")
//            let nsdataStr = NSData.init(data: data)
//            text = nsdataStr.description.trimmingCharacters(in: characterSet)//.replacingOccurrences(of: " ", with: "")
            text = data.binEncodedString()
        case .hex:
            text = data.hexEncodedString(options: .upperCase)
        default:
            text = String(data: data, encoding: String.Encoding.utf8) ?? "not supported"
        }
        
        readValueField.text = text
    }
    
    @IBAction func send(_ sender: Any) {
        
    }
    
    @IBAction func notifyAction(_ sender: Any) {
        
    }
    
    @IBAction func valueFormatAction(_ sender: UISegmentedControl) {
        valueFormat = ValueFormat(rawValue: sender.selectedSegmentIndex)!
        updateReadValueField()
    }
}

extension OperationViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed… error: \(error)")
            return
        }
        
        print("characteristic uuid: \(characteristic.uuid), value: \(String(describing: characteristic.value))")
        DispatchQueue.main.async { [unowned self] in
            self.updateReadValueField()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}

