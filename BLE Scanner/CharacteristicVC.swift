//
//  CharacteristicVC.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 08.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicVC: UITableViewController {

	var props = [CBCharacteristicProperties]()
	var peripharal: CBPeripheral!
	var characteristic: CBCharacteristic! {
		didSet {
			title = characteristic.UUID.description
			props.removeAll()
			if characteristic.properties.contains(.Read) {
				props.append(.Read)
			}
			if characteristic.properties.contains(.Write) {
				props.append(.Write)
			}
			if characteristic.properties.contains(.Notify) {
				props.append(.Notify)
			}
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 80
	}

    // MARK: Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return props.count
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CharacteristicAccessCell, forIndexPath: indexPath) as! CharacteristicAccessCell

		cell.peripharal = peripharal
		cell.characteristic = characteristic
		cell.prop = props[indexPath.section]

        return cell
    }

}

// MARK: -

class CharacteristicAccessCell: UITableViewCell {
	var peripharal: CBPeripheral!
	var characteristic: CBCharacteristic! {
		didSet {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateValueForCharacteristic:", name: Constants.DidUpdateValueForCharacteristic, object: nil)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "didWriteValueForCharacteristic:", name: Constants.DidWriteValueForCharacteristic, object: nil)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateNotificationStateForCharacteristic:", name: Constants.DidUpdateNotificationStateForCharacteristic, object: nil)
//			NSNotificationCenter.defaultCenter().removeObserver(self)
		}
	}
	var prop: CBCharacteristicProperties! {
		didSet {
			setPropertyLabel()
		}
	}
	var requesting = false
	
	@IBOutlet weak var propertyLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var valueTextField: UITextField!
	
	@IBAction func doAction() {
		switch prop {
		case CBCharacteristicProperties.Read:
			peripharal.readValueForCharacteristic(characteristic)
			requesting = true
		case CBCharacteristicProperties.Write:
			if let value = valueTextField.text?.dataUsingEncoding(NSUTF8StringEncoding) {
				peripharal.writeValue(value, forCharacteristic: characteristic, type: .WithResponse)
				requesting = true
			}
		case CBCharacteristicProperties.Notify:
			actionButton.selected = !actionButton.selected
			peripharal.setNotifyValue(actionButton.selected, forCharacteristic: characteristic)
			requesting = actionButton.selected
		default: break
		}
	}
	
	func setPropertyLabel() {
		switch prop {
		case CBCharacteristicProperties.Read:
			propertyLabel?.text = "Readable"
			actionButton?.setTitle("Read", forState: .Normal)
		case CBCharacteristicProperties.Write:
			propertyLabel?.text = "Writeable"
			actionButton?.setTitle("Write", forState: .Normal)
		case CBCharacteristicProperties.Notify:
			propertyLabel?.text = "Notifyable"
			actionButton?.setTitle("Subscribe", forState: .Normal)
			actionButton?.setTitle("Unsubscribe", forState: .Selected)
			actionButton?.selected = characteristic.isNotifying
			requesting = characteristic.isNotifying
		default: break
		}
	}
	
	// MARK: observing
	
	func didUpdateValueForCharacteristic(notification: NSNotification) {
		guard requesting else { return }
		requesting = prop == .Notify ? requesting : false
		guard let characteristic = notification.object as? CBCharacteristic else { return }
		guard characteristic.UUID.isEqual(self.characteristic.UUID) else { return }
		if let error = notification.userInfo?["error"] as? NSError {
			valueTextField.text = nil
			valueTextField.placeholder = error.localizedDescription
		} else {
			if let value = characteristic.value {
				valueTextField.text = String(data: value, encoding: NSUTF8StringEncoding)
			} else {
				valueTextField.text = nil
			}
			valueTextField.placeholder = "no value"
		}
	}
	
	func didWriteValueForCharacteristic(notification: NSNotification) {
		guard requesting else { return }
		requesting = false
		guard let characteristic = notification.object as? CBCharacteristic else { return }
		guard characteristic.UUID.isEqual(self.characteristic.UUID) else { return }
		if let error = notification.userInfo?["error"] as? NSError {
			valueTextField.text = nil
			valueTextField.placeholder = error.localizedDescription
		} else {
			NSLog("ok \(characteristic.value)")
		}
	}
	
	func didUpdateNotificationStateForCharacteristic(notification: NSNotification) {
		guard requesting else { return }
		guard let characteristic = notification.object as? CBCharacteristic else { return }
		guard characteristic.UUID.isEqual(self.characteristic.UUID) else { return }
		if let error = notification.userInfo?["error"] as? NSError {
			valueTextField.text = nil
			valueTextField.placeholder = error.localizedDescription
		} else {
			if let value = characteristic.value {
				valueTextField.text = String(data: value, encoding: NSUTF8StringEncoding)
			} else {
				valueTextField.text = nil
			}
			valueTextField.placeholder = "no value"
		}
	}
}
