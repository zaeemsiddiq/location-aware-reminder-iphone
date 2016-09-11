//
//  Protocols.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import Foundation
protocol addCategoryDelegate {
    func addCategory(category: Category)
}
protocol addReminderDelegate {
    func addReminder(reminder: Reminder)
}

protocol addLocationDelegate {
    func addLocation( location: Location)
}