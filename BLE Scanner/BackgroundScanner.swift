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
	var peripherals = [(peripheral: CBPeripheral, date: NSDate)]()
	var on = false
	
	override init() {
		super.init()
		centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : "BLE_Scanner"])
	}
	
	func startScan() {
		if centralManager.state == .PoweredOn && on {
			NSLog("background scanning start")
			centralManager.scanForPeripheralsWithServices(UUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
		}
	}
	func stopScan() {
		NSLog("background scanning stop")
		centralManager.stopScan()
	}
	
	func containsUUID(uuid: CBUUID) -> Bool {
		return UUIDs.contains { uuid.isEqual($0) }
	}
	func addUUID(uuid: CBUUID) {
		if !containsUUID(uuid) {
			UUIDs.append(uuid)
			delegate?.updateUUIDs()
		}
	}
	func removeUUID(uuid: CBUUID) {
		if let index = UUIDs.indexOf(uuid) {
			UUIDs.removeAtIndex(index)
			delegate?.updateUUIDs()
		}
	}
	
	// MARK: Central Manager delegate
	
	func centralManagerDidUpdateState(central: CBCentralManager) {
		startScan()
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		let alreadyFound = peripherals.contains { (p: CBPeripheral, date: NSDate) -> Bool in
			return p.name == peripheral.name
				&& p.identifier.isEqual(peripheral.identifier)
				&& NSDate().timeIntervalSinceDate(date) < 10 * 60
		}
		guard !alreadyFound else { return }
		
		NSLog("didDiscoverPeripheral \(peripheral)")
		
		peripherals.append((peripheral, NSDate()))
		delegate?.updatePeripherals()
		
		let notif = UILocalNotification()
		notif.alertBody = peripheral.name
		if #available(iOS 8.2, *) {
		    notif.alertTitle = peripheral.identifier.UUIDString
		}
		notif.soundName = UILocalNotificationDefaultSoundName
		notif.applicationIconBadgeNumber = peripherals.count
		UIApplication.sharedApplication().presentLocalNotificationNow(notif)
	}
	
	func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
		NSLog("willRestoreState \(dict)")
	}
}