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
	
	var peripheral: CBPeripheral!
	var advertisementDataUUIDs: [CBUUID]!

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
		tableView.reloadData()
	}

    // MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return advertisementDataUUIDs.count
		case 1:
			return peripheral.services?.count ?? 0
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
			cell.textLabel?.text = "\(advertisementDataUUIDs[indexPath.row])"
			cell.accessoryType = .None
		case 1:
			let service = peripheral.services![indexPath.row]
			cell.textLabel?.text = "\(service.UUID)"
			cell.detailTextLabel?.text = service.description
			cell.accessoryType = .DisclosureIndicator
		default: break
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 1
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}