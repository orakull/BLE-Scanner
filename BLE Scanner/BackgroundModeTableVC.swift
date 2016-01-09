//
//  BackgroundModeTableVC.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 08.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

class BackgroundModeTableVC: UITableViewController, BackgroundScannerDelegate {
	
	let dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		df.timeStyle = .MediumStyle
		return df
	}()
	
	var scanner: BackgroundScanner!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		scanner = BackgroundScanner.defaultScanner
		scanner.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func updateUUIDs() {
		tableView.reloadData()
	}
	
	func updatePeripherals() {
		tableView.reloadData()
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return scanner.UUIDs.count
		case 2:
			return scanner.peripherals.count
		default:
			return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		switch indexPath.section{
		case 0:
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SwitcherCell, forIndexPath: indexPath) as! SwitcherCell
			cell.switcher.on = scanner.on
			cell.onSwitchFunc = { self.scanner.on = $0 }
			return cell
		case 1:
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ScanUUIDCell, forIndexPath: indexPath)
			let uuid = scanner.UUIDs[indexPath.row]
			cell.textLabel?.text = uuid.description
			if #available(iOS 7.1, *) {
			    cell.detailTextLabel?.text = uuid.UUIDString
			} else {
			    cell.detailTextLabel?.text = nil
			}
			return cell
		case 2:
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.FindedPeripheralCell, forIndexPath: indexPath)
			let tuple = scanner.peripherals[indexPath.row]
			cell.textLabel?.text = "\(tuple.peripheral.name ?? "<no name>")"
			cell.detailTextLabel?.text = "(\(dateFormatter.stringFromDate(tuple.date))) \(tuple.peripheral.identifier.UUIDString)"
			return cell
		default:
			return UITableViewCell()
		}
		
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Settings"
		case 1:
			return "UUIDs for scan"
		case 2:
			return "finded peripherals"
		default:
			return nil
		}
	}
	
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 1
	}
	
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return [1, 2].contains(indexPath.section)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
			switch indexPath.section {
			case 1:
				let uuid = scanner.UUIDs[indexPath.row]
				scanner.removeUUID(uuid)
			case 2:
				scanner.peripherals.removeAtIndex(indexPath.row)
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
			default: break
			}
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let editUUID_VC = segue.destinationViewController as? EditUUID_VC {
			guard let indexPath = tableView.indexPathForSelectedRow else { return }
			guard indexPath.section == 1 else { return }
			let uuid = scanner.UUIDs[indexPath.row]
			editUUID_VC.uuid = uuid
		}
    }
	
	@IBAction func unwindFromChildVC(segue: UIStoryboardSegue) {
		if segue.identifier == "save" {
			guard let editUUID_VC = segue.sourceViewController as? EditUUID_VC else { return }
			guard let uuidString = editUUID_VC.uuidTextField.text else { return }
			
			let uuid = CBUUID(string: uuidString) // TODO: validate
			scanner.addUUID(uuid)
		}
	}
	
}

class SwitcherCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var switcher: UISwitch!
	
	var onSwitchFunc: ((on: Bool) -> Void)?
	
	@IBAction func onSwitch() {
		if let onSwitchFunc = onSwitchFunc {
			onSwitchFunc(on: switcher.on)
		}
	}
}
