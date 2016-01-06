//
//  DeviceTableVC.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 31.12.15.
//  Copyright © 2015 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Constants {
	static let PeripheralCell = "PeripheralCell"
	static let ServiceCell = "ServiceCell"
}

class PeripheralTableVC: UITableViewController, CBCentralManagerDelegate {
	
	var centralManager: CBCentralManager!
	
	var peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
	
	var scanning: Bool = false {
		didSet {
			title = scanning ? "Scanning..." : "Peripherals"
			scanStopButtonItem.title = scanning ? "Stop" : "Scan"
			
			if scanning {
//				let uuid1 = CBUUID(string: "180A")
//				let uuid2 = CBUUID(string: "180D")
//				centralManager.scanForPeripheralsWithServices([uuid1, uuid2], options: nil)
				
//				let uuid = CBUUID(string: "BD0F6577-4A38-4D71-AF1B-4E8F57708080")
//				centralManager.scanForPeripheralsWithServices([uuid], options: nil)
				
				peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
				tableView.reloadData()
				
				centralManager.scanForPeripheralsWithServices(nil, options: nil)
				NSLog("scanning...")
			} else {
				centralManager.stopScan()
				NSLog("scanning stopped.")
			}
		}
	}

	@IBOutlet weak var scanStopButtonItem: UIBarButtonItem!
	@IBAction func scanStop(sender: AnyObject? = nil) {
		scanning = !scanning
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60

		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "BLEScanner"])
    }
	
	// MARK: - Central Manager Delegate

	func centralManagerDidUpdateState(central: CBCentralManager) {
		NSLog(centralManager.state.description)
		scanning = centralManager.state == .PoweredOn
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		NSLog("discovered \(peripheral.name ?? "Noname") RSSI: \(RSSI)\n\(advertisementData)")
		
		let contains = peripherals.contains { (peripheralInner: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?) -> Bool in
			return peripheral == peripheralInner
		}
		
		if !contains {
			if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
				let UUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as! [CBUUID]
				peripherals.append((peripheral, serviceUUIDs.count, UUIDs))
			} else {
				peripherals.append((peripheral, 0, nil))
			}
		}
		
		
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		let notif = UILocalNotification()
		notif.alertBody = peripheral.name
		notif.soundName = UILocalNotificationDefaultSoundName
		UIApplication.sharedApplication().presentLocalNotificationNow(notif)
		
		tableView.reloadData()
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		NSLog("didConnectPeripheral \(peripheral.name)")
		tableView.reloadData()
		
		if let serviceTableVC = navigationController?.topViewController as? ServiceTableVC {
			peripheral.delegate = serviceTableVC
		}
		peripheral.discoverServices(nil)
	}
	
	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		NSLog("didDisconnectPeripheral \(peripheral.name)")
		tableView.reloadData()
	}
	
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		NSLog("didFailToConnectPeripheral \(peripheral.name)")
		tableView.reloadData()
	}
	
	func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
		NSLog("willRestoreState \(dict)")
	}

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PeripheralCell, forIndexPath: indexPath) as! PeripheralCell

        let peripheralCouple = peripherals[indexPath.row]

		cell.headerLabel.text = peripheralCouple.peripheral.name
		cell.descriptionLabel.text = "Services: \(peripheralCouple.serviceCount)\n\(peripheralCouple.peripheral.description)"

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let indexPath = tableView.indexPathForSelectedRow!
		let peripheralCouple = peripherals[indexPath.row]
		let peripheral = peripheralCouple.peripheral
		if let serviceTVC = segue.destinationViewController as? ServiceTableVC {
			serviceTVC.peripheral = peripheral
			serviceTVC.title = peripheral.name
			serviceTVC.advertisementDataUUIDs = peripheralCouple.UUIDs
			if peripheral.state != .Connected {
				NSLog("connectPeripheral \(peripheral.name) (\(peripheral.state.description))")
				centralManager.connectPeripheral(peripheral, options: nil)
			} else {
				peripheral.delegate = serviceTVC
			}
		}
		tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

}

extension CBPeripheralState {
	var description: String {
		switch self {
		case .Connecting:
			return "Connecting"
		case .Connected:
			return "Connected"
		case .Disconnecting:
			return "Disconnecting"
		case .Disconnected:
			return "Disconnected"
		}
	}
}

extension CBCentralManagerState {
	var description: String {
		switch self {
		case .PoweredOff:
			return "PoweredOff"
		case .PoweredOn:
			return "PoweredOn"
		case .Resetting:
			return "Resetting"
		case .Unauthorized:
			return "Unauthorized"
		case .Unknown:
			return "Unknown"
		case .Unsupported:
			return "Unsupported"
		}
	}
}
