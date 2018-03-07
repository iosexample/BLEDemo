//
//  BLEListViewController.swift
//  BLEDemo
//
//  Created by dong on 6/3/2018.
//  Copyright © 2018 dong. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEListViewController: UITableViewController {
    var centralManager: CBCentralManager?
    var peripherals: [CBPeripheral] = []
    
    @IBOutlet weak var stopButtionItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle("Scanning Devices..")
        centralManager = CBCentralManager(delegate: self,
                                          queue: DispatchQueue(label: "BLE_QUEUE"),
                                          options: nil)
    }

    func scan() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func updateTitle(_ text: String) {
        title = text
    }
    
    @IBAction func stop(_ sender: Any) {
        stopButtionItem.isEnabled = false
        centralManager?.stopScan()
        updateTitle("Found \(peripherals.count) Devices")
    }
    
    @IBAction func refresh(_ sender: Any) {
        stopButtionItem.isEnabled = true
        peripherals.removeAll()
        tableView.reloadData()
        scan()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name == nil ? peripheral.identifier.uuidString : peripheral.name
        cell.detailTextLabel?.text = "\(peripheral.state)=\(peripheral.state.rawValue)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        stop(peripheral)
        centralManager?.connect(peripheral, options: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let peripheral = peripherals[indexPath.row]
            let vc = segue.destination as! ServicesViewController
            vc.peripheral = peripheral
            peripheral.delegate = vc
        }
    }

}

extension BLEListViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state.hashValue)")
        if central.state == .poweredOn {
            scan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral
        peripheral: CBPeripheral, error: Error?) {
        print("peripheral didDisconnectPeripheral: \(peripheral), error: \(error.debugDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral didConnect: \(peripheral), peripheral: \(peripheral)")
        peripheral.discoverServices(nil)
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("peripheral: \(peripheral), rssi: \(RSSI)")
        
        let exist = peripherals.contains { (p) -> Bool in
            return p.identifier.uuidString == peripheral.identifier.uuidString
        }
        
        if !exist {
            peripherals.append(peripheral)
            
            DispatchQueue.main.async { [unowned self] in
                self.updateTitle("Scanning Devices..\(self.peripherals.count)")
                self.tableView.reloadData()
            }
        }
    }
}
