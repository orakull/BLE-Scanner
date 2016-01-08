//
//  CharacteristicTableVV.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 07.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicTableVC: UITableViewController {
	
	var peripharal: CBPeripheral!
	var service: CBService!

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.characteristics?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CharacteristicCell, forIndexPath: indexPath)

		if let characteristic = service.characteristics?[indexPath.row] {
			cell.textLabel?.text = characteristic.UUID.description
			cell.detailTextLabel?.text = characteristic.properties.description
		}

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		guard let characteristic = service.characteristics?[indexPath.row] else { return }
		guard let characteristicVC = segue.destinationViewController as? CharacteristicVC else { return }
		characteristicVC.characteristic = characteristic
		characteristicVC.peripharal = peripharal
    }

}
