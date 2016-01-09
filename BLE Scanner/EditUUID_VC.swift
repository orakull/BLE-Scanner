//
//  EditUUID_VC.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 09.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit
import CoreBluetooth

class EditUUID_VC: UIViewController {
	
	var uuid = CBUUID(NSUUID: NSUUID()) {
		didSet {
			if #available(iOS 7.1, *) {
			    uuidTextField?.text = uuid.UUIDString
			} else {
				uuidTextField?.text = uuid.description
			}
		}
	}

	@IBOutlet weak var uuidTextField: UITextField! {
		didSet {
			if #available(iOS 7.1, *) {
				uuidTextField?.text = uuid.UUIDString
			} else {
				uuidTextField?.text = uuid.description
			}
		}
	}
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	@IBAction func cancel(sender: AnyObject) {
	}
	@IBAction func save(sender: AnyObject) {
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		uuidTextField.becomeFirstResponder()
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
