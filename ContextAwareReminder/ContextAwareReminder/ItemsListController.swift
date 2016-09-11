//
//  ItemsListController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData

class ItemsListController: UITableViewController, addReminderDelegate {

    var managedObjectContext: NSManagedObjectContext
    var remindersList: NSMutableArray   // holds the items
    var currentCategory: Category?
    var currentReminder: Reminder?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false  // as it overlaps its children navigation bars thats y i had to programatically hide it
    }
    
    required init?(coder aDecoder: NSCoder) {
        remindersList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshList()
        sort()
    }
    
    // adding the reminder from EditReminder View
    func addReminder(reminder: Reminder) {
        self.currentCategory?.addReminder(reminder)
        do
        {
            try self.managedObjectContext.save()
        }
        catch let error
        {
            print("Could not save Deletion \(error)")
        }
        // refresh the list here
        refreshList()
        sort()
    }
    
    // refresh the lost here, based on the contents, display an appropriate message otherwise just load the contents
    func refreshList() {
        // code taken from http://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen
        
        // we are just adding a text label, so that we can display an appropriate message instead of tableView
        if(currentCategory == nil) {
            let noDataLabel: UILabel     = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text             = "Please select a category do display its items"
            noDataLabel.textColor        = UIColor.blackColor()
            noDataLabel.textAlignment    = .Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        } else if (currentCategory?.reminders?.count == 0) {
            let noDataLabel: UILabel     = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text             = "No items to display"
            noDataLabel.textColor        = UIColor.blackColor()
            noDataLabel.textAlignment    = .Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        } else {
            self.remindersList = NSMutableArray(array: (currentCategory!.reminders?.allObjects as! [Reminder]))
            self.tableView.reloadData()
        }
        
    }
    
    // sorting on the basis of date set
    func sort() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        let arr = self.remindersList.sort {($0.valueForKey("datetime") as! NSDate).compare($1.valueForKey("datetime") as! NSDate) == .OrderedDescending }
        self.remindersList = arr as! NSMutableArray
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.remindersList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("ItemsListCell", forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemsListCell", forIndexPath: indexPath) as! ItemListCell
        // Configuring the cell...
        // here i am adding a touch event listener to my switch which will initiate method to save enabled and disabled variables
        // code taken from http://stackoverflow.com/questions/24814646/attach-parameter-to-button-addtarget-action-in-swift
        // i am setting the selector tag as indexpath.row so that when the switches state is changed, we get the tag as row number from the switch
        
        let rem: Reminder = self.remindersList[indexPath.row] as! Reminder
        
        // comparing the reminders time with todays time, NOTE that we are comparing to the HOUR level, changing the color to red code is taken from
        //http://stackoverflow.com/questions/24577087/comparing-nsdates-without-time-component
        let now = NSDate()
        
        let order = NSCalendar.currentCalendar().compareDate(now, toDate: rem.datetime!,
                                                             toUnitGranularity: .Hour)
        switch order {
        case .OrderedDescending:    // overdue
            cell.itemTitle.textColor = UIColor.redColor()
        case .OrderedAscending:     // yet to come
            print("ASCENDING")
        case .OrderedSame:
           cell.itemTitle.textColor = UIColor.redColor()
        }
        
        cell.itemTitle.text = rem.title
        
        // setting the item switch and attaching the listener to it
        cell.itemSwitch.tag = indexPath.row
        cell.itemSwitch.addTarget(self, action: #selector(ItemsListController.switchChanged(_:)), forControlEvents:UIControlEvents.AllTouchEvents)
        cell.itemSwitch.setOn((rem.status == 1 ? true: false), animated: true) // as it is NSNumber so 1 translates to T and F otherwise
        return cell
    }

    // function gets fired when we change a position of a switch from the table
    func switchChanged(sender: UISwitch) {
        let rem: Reminder = self.remindersList[sender.tag] as! Reminder
        if sender.on {
            sender.setOn(true, animated: true)
            rem.status = 1
        } else {
            sender.setOn(false, animated: true)
            rem.status = 0
        }
        // refresh the data
        refreshList()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        // same concept, set the variable before jumping to the next screen, otherwise screen will behave as it is entering a new reminder instead of editing the current one 
        if segue.identifier == "addReminderSegue" {
            let editReminderSegue:EditReminderController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! EditReminderController
            editReminderSegue.delegate = self
            editReminderSegue.managedObjectContext = self.managedObjectContext
        } else if segue.identifier == "editReminderSegue" {
            
            let editReminderSegue:EditReminderController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! EditReminderController
            editReminderSegue.delegate = self
            editReminderSegue.managedObjectContext = self.managedObjectContext
            
            if let selectedReminderCell = sender as? ItemListCell {
                let indexPath = tableView.indexPathForCell(selectedReminderCell)!
                editReminderSegue.currentReminder = self.remindersList.objectAtIndex(indexPath.row) as? Reminder                
            }
        }
    }
    

}
