//
//  Reminder+CoreDataProperties.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var datetime: NSDate?
    @NSManaged var note: String?
    @NSManaged var status: NSNumber?
    @NSManaged var title: String?
    @NSManaged var belongsto: NSSet?

}
