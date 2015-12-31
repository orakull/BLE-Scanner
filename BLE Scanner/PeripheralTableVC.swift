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
}

class PeripheralTableVC: UITableViewController, CBCentralManagerDelegate {
	
	var centralManager: CBCentralManager!
	
	var peripherals = [CBPeripheral]()

	@IBAction func scan(sender: AnyObject? = nil) {
		print("scanning...")
		peripherals = [CBPeripheral]()
		tableView.reloadData()
		centralManager.scanForPeripheralsWithServices(nil, options: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		centralManager = CBCentralManager(delegate: self, queue: nil)
    }

	func centralManagerDidUpdateState(central: CBCentralManager) {
		print(centralManager.state.description)
		if centralManager.state == .PoweredOn {
			scan()
		}
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		if !peripherals.contains(peripheral) {
			peripherals.append(peripheral)
			print("discovered \(peripheral.name ?? "Noname") RSSI: \(RSSI)\n\(advertisementData)")
		}
		
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		let notif = UILocalNotification()
		notif.alertBody = peripheral.name
		notif.soundName = UILocalNotificationDefaultSoundName
//		notif.fireDate = NSDate(timeIntervalSinceNow: 1)
		UIApplication.sharedApplication().presentLocalNotificationNow(notif)
//		UIApplication.sharedApplication().scheduleLocalNotification(notif)
		
		
		tableView.reloadData()
	}
	

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PeripheralCell, forIndexPath: indexPath)

        let peripheral = peripherals[indexPath.row]
		
		cell.textLabel?.text = peripheral.name
		cell.detailTextLabel?.text = peripheral.description

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
