//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var radius: NSNumber?
    @NSManaged var belongsto: Category?

}
