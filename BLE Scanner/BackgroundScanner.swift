//
//  BackgroundScanner.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 08.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BackgroundScannerDelegate {
	func updateUUIDs()
	func updatePeripherals()
}

class BackgroundScanner: NSObject, CBCentralManagerDelegate {
	static let defaultScanner = BackgroundScanner()
	
	var delegate: BackgroundScannerDelegate?
	
	var centralManager: CBCentralManager!
	var UUIDs = [CBUUID]()
//	var UUIDs = [CBUUID(string: "180D")]
	var peripherals = [(peripheral: CBPeripheral, date: NSDate)]()
	var on = false {
		didSet {
			if on {
				centralManager.scanForPeripheralsWithServices(UUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
			} else {
				centralManager.stopScan()
			}
		}
	}
	
	override init() {
		super.init()
		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : "BLE_Scanner"])
	}
	
	func startScan() {
		if centralManager.state == .PoweredOn && on {
			NSLog("background scanning")
			centralManager.scanForPeripheralsWithServices(UUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
		}
	}
	func refreshScan() {
		centralManager.stopScan()
		startScan()
	}
	
	func containsUUID(uuid: CBUUID) -> Bool {
		return UUIDs.contains { uuid.isEqual($0) }
	}
	func addUUID(uuid: CBUUID) {
		if !containsUUID(uuid) {
			UUIDs.append(uuid)
			refreshScan()
			delegate?.updateUUIDs()
		}
	}
	func removeUUID(uuid: CBUUID) {
		if let index = UUIDs.indexOf(uuid) {
			UUIDs.removeAtIndex(index)
			refreshScan()
			delegate?.updateUUIDs()
		}
	}
	
	// MARK: Central Manager delegate
	
	func centralManagerDidUpdateState(central: CBCentralManager) {
		startScan()
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		NSLog("didDiscoverPeripheral \(peripheral)")
		let alreadyFound = peripherals.contains { (p: CBPeripheral, date: NSDate) -> Bool in
			return p.name == peripheral.name
				&& p.identifier.isEqual(peripheral.identifier)
				&& NSDate().timeIntervalSinceDate(date) < 10 // * 60
		}
		guard !alreadyFound else { NSLog("already found"); return }
		
		peripherals.append((peripheral, NSDate()))
		delegate?.updatePeripherals()
		
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		let notif = UILocalNotification()
		notif.alertBody = peripheral.name
		if #available(iOS 8.2, *) {
		    notif.alertTitle = peripheral.identifier.UUIDString
		}
		notif.soundName = UILocalNotificationDefaultSoundName
		UIApplication.sharedApplication().presentLocalNotificationNow(notif)
	}
	
	func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
		NSLog("willRestoreState \(dict)")
	}
}