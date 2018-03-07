//
//  CharacterViewController.swift
//  BLEDemo
//
//  Created by dong on 6/3/2018.
//  Copyright © 2018 dong. All rights reserved.
//

import UIKit
import CoreBluetooth
class CharacterViewController: UITableViewController {
    var service: CBService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func propertiesString(_ properties: CBCharacteristicProperties) -> String {
        var string = ""
        
        if properties.contains(.authenticatedSignedWrites) {
            string.append(" ASW")
        }
        if properties.contains(.broadcast) {
            string.append(" Broadcast")
        }
        if properties.contains(.extendedProperties) {
            string.append(" EP")
        }
        if properties.contains(.indicate) {
            string.append(" Indicate")
        }
        if properties.contains(.indicateEncryptionRequired) {
            string.append(" IndicateER")
        }
        if properties.contains(.notify) {
            string.append(" Notify")
        }
        if properties.contains(.notifyEncryptionRequired) {
            string.append(" NotifyER")
        }
        if properties.contains(.read) {
            string.append(" Read")
        }
        if properties.contains(.write) {
            string.append(" Write")
        }
        if properties.contains(.writeWithoutResponse) {
            string.append(" WriteWR")
        }
        
        if string.count == 0 {
            string = "Unknow"
        }
        
        return string
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service?.characteristics?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let character = service?.characteristics?[indexPath.row] {
            cell.textLabel?.text = "\(character.uuid)"
            cell.detailTextLabel?.text = "\(character.uuid.uuidString) Properties: \(propertiesString(character.properties))"
        }
        else {
            cell.textLabel?.text = "Characteristic is nil"
            cell.detailTextLabel?.text = "nil Properties: nil"
        }
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let characteristic = service?.characteristics?[indexPath.row]
            let vc = segue.destination as! OperationViewController
            vc.characteristic = characteristic
        }
    }
}

