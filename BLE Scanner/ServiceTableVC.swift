//
//  ServiceTableVC.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 03.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceTableVC: UITableViewController, CBPeripheralDelegate {
	
	var discovering = true
	
	var peripheral: CBPeripheral!
	var advertisementDataUUIDs: [CBUUID]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Peripheral delegate
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		if let error = error {
			NSLog("didDiscoverServices error: \(error.localizedDescription)")
		} else {
			NSLog("didDiscoverServices \(peripheral.services?.count)")
		}
		discovering = false
		tableView.reloadData()
		
		if let services = peripheral.services {
			for service in services {
				peripheral.discoverCharacteristics(nil, forService: service)
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		if let error = error {
			NSLog("didDiscoverCharacteristicsForService error: \(error.localizedDescription)")
		} else {
			NSLog("didDiscoverCharacteristicsForService \(service.characteristics?.count)")
			if let row = peripheral.services?.indexOf(service) {
				let indexPath = NSIndexPath(forRow: row, inSection: 1)
				tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if let error = error {
			NSLog("didUpdateValueForCharacteristic error: \(error.localizedDescription)")
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidUpdateValueForCharacteristic, object: characteristic, userInfo: ["error": error])
		} else {
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidUpdateValueForCharacteristic, object: characteristic)
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if let error = error {
			NSLog("didWriteValueForCharacteristic error: \(error.localizedDescription)")
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidWriteValueForCharacteristic, object: characteristic, userInfo: ["error": error])
		} else {
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidWriteValueForCharacteristic, object: characteristic)
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if let error = error {
			NSLog("didUpdateNotificationStateForCharacteristic error: \(error.localizedDescription)")
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidUpdateNotificationStateForCharacteristic, object: characteristic, userInfo: ["error": error])
		} else {
			NSNotificationCenter.defaultCenter().postNotificationName(Constants.DidUpdateNotificationStateForCharacteristic, object: characteristic)
		}
	}

    // MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return advertisementDataUUIDs?.count ?? 0
		case 1:
			let number = peripheral.services?.count ?? 0
			return number + (discovering ? 1 : 0)
		default:
			return 0
		}
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return ["Advertisement Data", "Services"][section]
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ServiceCell, forIndexPath: indexPath)
		
		switch indexPath.section {
		case 0:
			if let uuid = advertisementDataUUIDs?[indexPath.row] {
				cell.textLabel?.text = uuid.description
				if #available(iOS 7.1, *) {
					cell.detailTextLabel?.text = uuid.UUIDString
				} else {
					cell.detailTextLabel?.text = ""
				}
				cell.accessoryType = .None
			}
		case 1:
			if let service = peripheral.services?[indexPath.row] {
				let uuid = service.UUID
				cell.textLabel?.text = uuid.description
				var details = ""
				if let characteristics = service.characteristics {
					details += "(characteristics: \(characteristics.count)) "
				}
				if #available(iOS 7.1, *) {
					details += uuid.UUIDString
				}
				cell.detailTextLabel?.text = details
				cell.accessoryType = service.characteristics == nil ? .None : .DisclosureIndicator
			} else {
				cell.textLabel?.text = "discovering..."
				cell.detailTextLabel?.text = ""
			}
		default: break
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		switch indexPath.section {
		case 0:
			return false
		case 1:
			guard let services = peripheral.services else { return false }
			guard services.count > 0 else { tableView.reloadData(); return false }
			guard let characteristics = services[indexPath.row].characteristics else { return false }
			return characteristics.count > 0
		default:
			return false
		}
	}

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let characteristicTableVC = segue.destinationViewController as? CharacteristicTableVC {
			let indexPath = tableView.indexPathForSelectedRow!
			if let service = peripheral.services?[indexPath.row] {
				characteristicTableVC.peripharal = peripheral
				characteristicTableVC.service = service
			}
		}
    }

}
