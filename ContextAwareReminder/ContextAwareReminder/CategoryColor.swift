//
//  CategoryColor.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/2/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit

enum CategoryColor: Int {
    case Blue, Red
    var color: UIColor{
        switch self {
        case .Blue:
            return UIColor.blueColor()
        case .Red:
            return UIColor.redColor()
        }
    }
}
