//
//  PeripheralCell.swift
//  BLE Scanner
//
//  Created by Руслан Ольховка on 03.01.16.
//  Copyright © 2016 Руслан Ольховка. All rights reserved.
//

import UIKit

class PeripheralCell: UITableViewCell {

	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
