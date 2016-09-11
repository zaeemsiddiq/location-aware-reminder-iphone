//
//  CategoryListController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/1/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData

class CategoryListController: UITableViewController, addCategoryDelegate {

    var managedObjectContext: NSManagedObjectContext    // used to handle transactions
    var categoryList: NSMutableArray    // array holding the list
    var currentCategory: Category?  // var holding the selected category
    var longPressRecognizer: UIGestureRecognizer?   // used to handle category edit function
    
    // setting up the environment
    required init?(coder aDecoder: NSCoder) {
        categoryList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    // if the mode is set to editting, i removed the long pressed gesture because it initiated the edit cat procedure, added back again if the table gets back from editting mode
    @IBAction func editButton(sender: AnyObject) {
        self.editing = !self.editing
        if (self.editing) {
            self.view.removeGestureRecognizer(longPressRecognizer!)
        } else {
            self.view.addGestureRecognizer(longPressRecognizer!)
        }
    }
    @IBAction func addCategoryButton(sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // attaching the long tap event in table view so that we can listen to long clicks in order to edit the categories
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector (CategoryListController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer!)
        
        loadData()
    }
    
    // code for controlling the long tap, taken from http://stackoverflow.com/questions/30839275/how-to-select-a-table-row-during-a-long-press-in-swift
    // this code returns the table row as index then we can send that object to edit category view
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if !self.editing {
            if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
                
                let touchPoint = longPressGestureRecognizer.locationInView(self.view)
                if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                    self.currentCategory = self.categoryList.objectAtIndex(indexPath.row) as? Category
                    self.performSegueWithIdentifier("editCategorySegue", sender:self)
                }
            }
        }
        
    }
    // delegate returned from edit cat screen , not that the category is added in the edit screen thats why we are just refreshing the list here
    func addCategory(category: Category) {  // refresh the list here
        loadData()
    }
    
    
    // loading the data into our category list here
    func loadData() {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Category", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        var result = NSArray?()
        do
        {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if result!.count > 0
            {
                self.categoryList.removeAllObjects()
                for res in result! {
                    self.currentCategory = res as? Category
                    self.categoryList.addObject(self.currentCategory!)
                }
                self.tableView.reloadData()
            }
            
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
        sortList()
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.categoryList.count
    }
    
    // we are sorting on the basis of order here. An item of order 1 will always be displayed before the one with order 4 .
    func sortList() {
        self.categoryList.sortUsingComparator{
            
            (obj1:AnyObject, obj2:AnyObject) -> NSComparisonResult in
            
            let p1 = obj1 as! Category
            let p2 = obj2 as! Category
            
            let result = p1.order!.compare(p2.order!)
            return result
        }
        tableView.reloadData()
    }
    // this function gets fired when we are editing the order of the table, The algorithm works in such a way that it detects whether we are promoting or demoting a category. Promotion sets indexes from top to bottom whereas demotion sets indexes from bottom to up
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        if toIndexPath.row < fromIndexPath.row {    // from below to above (promotion)
            
            // assign fromms order to to index
            let fromCat: Category = self.categoryList.objectAtIndex(fromIndexPath.row) as! Category
            fromCat.order = toIndexPath.row
            
            //start incrememnting all the below orders to +1
            
            for index in toIndexPath.row...self.categoryList.count {
                if index == fromIndexPath.row {
                    let walkerCat: Category = self.categoryList.objectAtIndex(toIndexPath.row) as! Category
                    walkerCat.order = toIndexPath.row
                } else {
                    let walkerCat: Category = self.categoryList.objectAtIndex(toIndexPath.row) as! Category
                    if (index == categoryList.count) {
                        walkerCat.order = index
                    } else {
                        walkerCat.order = index+1
                    }
                }
            }
            
        } else {    // demotion
            // assign fromms order to to index
            let fromCat: Category = self.categoryList.objectAtIndex(fromIndexPath.row) as! Category
            fromCat.order = toIndexPath.row
            
            //start decrementing all the above orders with 1
            for var index = toIndexPath.row; index >= fromIndexPath.row; index -= 1 {
                if index == fromIndexPath.row {
                    // ignore as we have already changed the index above
                } else {
                        let walkerCat: Category = self.categoryList.objectAtIndex(index) as! Category
                        walkerCat.order = index-1
                }
            }
        }
        
        //Save the ManagedObjectContext after the orders have been set
        do
        {
            try self.managedObjectContext.save()
        }
        catch let error {
            print("Could not save Deletion \(error)")
        }
        // sort and display
        sortList()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryListCell", forIndexPath: indexPath) as! CategoryListCell
                // Configure the cell...
        let cat: Category = self.categoryList[indexPath.row] as! Category
        cell.labelCategoryName.text = cat.title
        
        if cat.color == Constants.COLOR_RED {
            cell.labelCategoryName.textColor = UIColor.redColor()
        } else if cat.color == Constants.COLOR_ORANGE {
            cell.labelCategoryName.textColor = UIColor.orangeColor()
        } else if cat.color == Constants.COLOR_YELLOW {
            cell.labelCategoryName.textColor = UIColor.yellowColor()
        } else if cat.color == Constants.COLOR_GREEN {
            cell.labelCategoryName.textColor = UIColor.greenColor()
        } else if cat.color == Constants.COLOR_BLUE {
            cell.labelCategoryName.textColor = UIColor.blueColor()
        } else if cat.color == Constants.COLOR_PURPLE {
            cell.labelCategoryName.textColor = UIColor.purpleColor()
        } else if cat.color == Constants.COLOR_GREY {
            cell.labelCategoryName.textColor = UIColor.grayColor()
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            managedObjectContext.deleteObject(categoryList.objectAtIndex(indexPath.row) as! NSManagedObject)
             self.categoryList.removeObjectAtIndex(indexPath.row)
             tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            loadData()
             //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
             //Save the ManagedObjectContext
             do
                {
                try self.managedObjectContext.save()
             }
                    catch let error {
                  print("Could not save Deletion \(error)")
                 }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
        
        // add category segue jumps to EditCategoryController but without an object set to it, whereas view cat sets current object because we want to view in the same screen we are adding. similarly editting does the same function (sets the object before jumping to that screen)
        if segue.identifier == "addCategorySegue" {
            let editCategorySegue:EditCategoryController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! EditCategoryController
            editCategorySegue.delegate = self
            editCategorySegue.totalCategories = self.categoryList.count
            editCategorySegue.managedObjectContext = self.managedObjectContext
        } else if segue.identifier == "viewCategorySegue" {
            let itemsListSegue:ItemsListController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ItemsListController
            if let selectedReminderCell = sender as? CategoryListCell {
                let indexPath = tableView.indexPathForCell(selectedReminderCell)!
                itemsListSegue.currentCategory = self.categoryList.objectAtIndex(indexPath.row) as? Category
            }
           
        } else if segue.identifier == "editCategorySegue" {
            let editCategorySegue:EditCategoryController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! EditCategoryController
            editCategorySegue.delegate = self
            editCategorySegue.currentCategory = self.currentCategory
            editCategorySegue.totalCategories = self.categoryList.count
            editCategorySegue.managedObjectContext = self.managedObjectContext
            
        }
    }
    

}
