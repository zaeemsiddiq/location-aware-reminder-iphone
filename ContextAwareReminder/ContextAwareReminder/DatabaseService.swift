//
//  DatabaseService.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/1/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//  
//  This class is acting as an interface to the database. Every coredata function (CRUD) needs to be accessed through this class.
//  This is a singleton class, where the managedObjectContext initialised by appDelegate at the begining of app lifecycle.
import CoreData
import Foundation

class DatabaseService {
    static var managedObjectContext: NSManagedObjectContext!
}
