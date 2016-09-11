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
    var remindersList: NSMutableArray
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    /*
    required init?(coder aDecoder: NSCoder) {
        itemsList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }*/

    func addReminder(reminder: Reminder) {
        self.currentCategory?.addReminder(reminder)
        do
        {
            try self.managedObjectContext.save()
            self.remindersList = NSMutableArray(array: (currentCategory!.reminders?.allObjects as! [Reminder]))
        }
        catch let error
        {
            print("Could not save \(error)")
        }
        // refresh the list here
        refreshList()
    }
    
    func refreshList() {
            self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         
        // #warning Incomplete implementation, return the number of sections
        var numOfSections: Int = 0
        if self.remindersList.count == 0
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text             = "No items to display"
            noDataLabel.textColor        = UIColor.blackColor()
            noDataLabel.textAlignment    = .Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        }
        else
        {
            tableView.separatorStyle = .SingleLine
            numOfSections                = 1
            tableView.backgroundView = nil
            
        }
        return numOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.remindersList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("ItemsListCell", forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemsListCell", forIndexPath: indexPath) as! ItemListCell
        // Configure the cell...
        let rem: Reminder = self.remindersList[indexPath.row] as! Reminder
        cell.itemTitle.text = rem.title
        cell.itemSwitch.tag = indexPath.row
        cell.itemSwitch.addTarget(self, action: #selector(ItemsListController.switchChanged(_:)), forControlEvents:UIControlEvents.AllTouchEvents)
        cell.itemSwitch.setOn((rem.status == 1 ? true: false), animated: true) // as it is NSNumber so 1 translates to T and F otherwise
        return cell
    }

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
