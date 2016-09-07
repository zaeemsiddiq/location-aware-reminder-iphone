//
//  ItemListCell.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit

class ItemListCell: UITableViewCell {

    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
