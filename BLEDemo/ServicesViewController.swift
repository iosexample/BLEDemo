//
//  ServicesViewController.swift
//  BLEDemo
//
//  Created by dong on 6/3/2018.
//  Copyright © 2018 dong. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServicesViewController: UITableViewController {
    var peripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = peripheral?.name ?? peripheral?.identifier.uuidString
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        peripheral?.delegate = self
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let service = sender as? CBService {
            
            let vc = segue.destination as! CharacterViewController
            vc.service = service
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheral?.services?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let service = peripheral?.services?[indexPath.row]
        cell.textLabel?.text = "\(service!.uuid)"
        cell.detailTextLabel?.text = service?.uuid.uuidString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let service = peripheral?.services?[indexPath.row] {
            service.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}

extension ServicesViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("peripheral: \(peripheral), didDiscoverServices error: \(error.debugDescription)")
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("peripheral: \(peripheral), didReadRSSI:\(RSSI) error: \(error.debugDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("peripheral: \(peripheral), didDiscoverCharacteristicsFor service:\(service) error: \(error.debugDescription)")
        DispatchQueue.main.async { [unowned self] in
            self.performSegue(withIdentifier: "showCharacter", sender: service)
        }
    }
}
