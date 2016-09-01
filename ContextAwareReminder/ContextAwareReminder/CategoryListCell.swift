//
//  CategoryListCell.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/1/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit

class CategoryListCell: UITableViewCell {

    @IBOutlet weak var labelCategoryName: UILabel!
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var labelCategoryTotal: UILabel!
}
