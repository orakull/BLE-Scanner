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
	static let CharacteristicCell = "CharacteristicCell"
	static let CharacteristicAccessCell = "CharacteristicAccessCell"
	static let SwitcherCell = "SwitcherCell"
	static let ScanUUIDCell = "ScanUUIDCell"
	static let FindedPeripheralCell = "FindedPeripheralCell"
	
	static let ConnectTimeout: NSTimeInterval = 5
	static let DidUpdateValueForCharacteristic = "didUpdateValueForCharacteristic"
	static let DidWriteValueForCharacteristic = "didWriteValueForCharacteristic"
	static let DidUpdateNotificationStateForCharacteristic = "didUpdateNotificationStateForCharacteristic"
}

class PeripheralTableVC: UITableViewController, CBCentralManagerDelegate {
	
	var centralManager: CBCentralManager!
	
	var peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
	
	var connectTimer: NSTimer?
	
	var scanning = false {
		didSet {
			title = scanning ? "Scanning..." : "Peripherals"
			scanStopButtonItem.title = scanning ? "Stop" : "Scan"
			
			if scanning {
//				let uuid1 = CBUUID(string: "180A")
//				let uuid2 = CBUUID(string: "180D")
//				centralManager.scanForPeripheralsWithServices([uuid1, uuid2], options: nil)
				
//				let uuid = CBUUID(string: "BD0F6577-4A38-4D71-AF1B-4E8F57708080")
//				centralManager.scanForPeripheralsWithServices([uuid], options: nil)
				
				centralManager.scanForPeripheralsWithServices(nil, options: nil)
				NSLog("scanning...")
			} else {
				centralManager.stopScan()
				NSLog("scanning stopped.")
			}
		}
	}

	@IBAction func clear(sender: AnyObject) {
		peripherals = [(peripheral: CBPeripheral, serviceCount: Int, UUIDs: [CBUUID]?)]()
		tableView.reloadData()
		if scanning {
			scanning = false
			scanning = true
		}
	}
	@IBOutlet weak var scanStopButtonItem: UIBarButtonItem!
	@IBAction func scanStop(sender: AnyObject? = nil) {
		scanning = !scanning
	}
	
	func cancelConnections() {
		print("cancelConnections")
		for peripheralCouple in peripherals {
//			if peripheralCouple.peripheral.state == .Connected
//				|| peripheralCouple.peripheral.state == .Connecting {
				centralManager.cancelPeripheralConnection(peripheralCouple.peripheral)
//			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 60

		centralManager = CBCentralManager(delegate: self, queue: nil)
    }
	
	override func viewDidAppear(animated: Bool) {
		cancelConnections()
	}

	// MARK: - Central Manager Delegate

	func centralManagerDidUpdateState(central: CBCentralManager) {
		NSLog(centralManager.state.description)
		if centralManager.state != .PoweredOn {
			navigationController?.popToViewController(self, animated: true)
			if scanning {
				UIAlertView(title: "Unable to scan", message: "bluetooth is in \(centralManager.state.description)-state", delegate: nil, cancelButtonTitle: "Ok").show()
			}
			tableView.reloadData()
		}
		scanning = centralManager.state == .PoweredOn
		scanStopButtonItem.enabled = centralManager.state == .PoweredOn
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
		tableView.reloadData()
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		NSLog("didConnectPeripheral \(peripheral.name)")
		tableView.reloadData()
		
		connectTimer?.invalidate()
		
		if let serviceTableVC = navigationController?.topViewController as? ServiceTableVC {
			peripheral.delegate = serviceTableVC
		}
		peripheral.discoverServices(nil)
	}
	
	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		NSLog("didDisconnectPeripheral \(peripheral.name)")
		tableView.reloadData()
		navigationController?.popToViewController(self, animated: true)
	}
	
	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		NSLog("\tdidFailToConnectPeripheral \(peripheral.name)")
		tableView.reloadData()
		navigationController?.popToViewController(self, animated: true)
		UIAlertView(title: "Fail To Connect", message: nil, delegate: nil, cancelButtonTitle: "Dismiss").show()
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
		cell.accessoryType = centralManager.state == .PoweredOn ? .DisclosureIndicator : .None

        return cell
    }
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return centralManager.state == .PoweredOn
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
			connectTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.ConnectTimeout, target: self, selector: "cancelConnections", userInfo: nil, repeats: false)
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

extension CBCharacteristicProperties {
	var description: String {
		switch self {
		case CBCharacteristicProperties.Broadcast:
			return "Broadcast"
		case CBCharacteristicProperties.Read:
			return "Read"
		case CBCharacteristicProperties.WriteWithoutResponse:
			return "WriteWithoutResponse"
		case CBCharacteristicProperties.Write:
			return "Write"
		case CBCharacteristicProperties.Notify:
			return "Notify"
		case CBCharacteristicProperties.Indicate:
			return "Indicate"
		case CBCharacteristicProperties.AuthenticatedSignedWrites:
			return "AuthenticatedSignedWrites"
		case CBCharacteristicProperties.ExtendedProperties:
			return "ExtendedProperties"
		case CBCharacteristicProperties.NotifyEncryptionRequired:
			return "NotifyEncryptionRequired"
		case CBCharacteristicProperties.IndicateEncryptionRequired:
			return "IndicateEncryptionRequired"
		default:
			let array: [CBCharacteristicProperties] = [.Broadcast, .Read, .WriteWithoutResponse, .Write, .Notify, .Indicate, .AuthenticatedSignedWrites, .ExtendedProperties, .NotifyEncryptionRequired, .IndicateEncryptionRequired]
			return array.filter { self.contains($0) }.map { $0.description }.joinWithSeparator(", ")
		}
	}
}