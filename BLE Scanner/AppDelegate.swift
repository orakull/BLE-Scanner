//
//  AppDelegate.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 30.12.15.
//  Copyright © 2015 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	lazy var peripheralTableVC: PeripheralTableVC = PeripheralTableVC()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		if #available(iOS 8.0, *) {
			let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
		    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		} else {
		    print("can't register for local user notifications")
		}
		
		if let launchOptions = launchOptions {
			let centrals = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey]
			print(centrals)
			
			NSLog("find centrals \(centrals)")
			
//			let notif = UILocalNotification()
//			notif.alertBody = "ok!"
//			notif.soundName = UILocalNotificationDefaultSoundName
//			UIApplication.sharedApplication().presentLocalNotificationNow(notif)
//			
//			if let centrals = centrals as? [String] {
//				for central in centrals {
//					print(central)
//					peripheralTableVC.centralManager = CBCentralManager(delegate: peripheralTableVC, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: central])
//				}
//			}
			
		}
		
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		print("applicationWillResignActive")
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		print("applicationDidEnterBackground")
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		print("applicationWillTerminate")
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

