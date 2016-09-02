//
//  Category+CoreDataProperties.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/2/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var title: String?
    @NSManaged var color: NSNumber?
    @NSManaged var order: NSNumber?
    @NSManaged var notification: NSNumber?
    @NSManaged var location: NSSet?
    @NSManaged var reminders: NSSet?

}
