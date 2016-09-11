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

    var managedObjectContext: NSManagedObjectContext
    var categoryList: NSMutableArray
    var currentCategory: Category?
    var longPressRecognizer: UIGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        categoryList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.editing = !self.editing
        if (self.editing) {
            self.view.removeGestureRecognizer(longPressRecognizer!)
        } else {
            self.view.addGestureRecognizer(longPressRecognizer!)
        }
    }
    @IBAction func addCategoryButton(sender: AnyObject) {
        //self.performSegueWithIdentifier("editCategorySegue", sender:self)
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
    
    func addCategory(category: Category) {  // refresh the list here
        loadData()
    }
    
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
        var numOfSections: Int = 0
        /*if self.categoryList.count == 0
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
           
        }*/
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.categoryList.count
    }
    func sortList() {
        self.categoryList.sortUsingComparator{
            
            (obj1:AnyObject, obj2:AnyObject) -> NSComparisonResult in
            
            let p1 = obj1 as! Category
            let p2 = obj2 as! Category
            
            let result = p1.order!.compare(p2.order!)
            return result
        }
        //self.categoryList = tempArr
        print("printing sorted array \(categoryList.count)")
        if categoryList.count != 0 {
            for index in 0...categoryList.count-1 {
                let walkerCat: Category = categoryList.objectAtIndex(index) as! Category
                print("name = \(walkerCat.title) order = \(walkerCat.order) ")
            }
        }
        
        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        print("from \(fromIndexPath.row) to \(toIndexPath.row)")
        
        
        
        
        
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
        
        //Save the ManagedObjectContext
        do
        {
            try self.managedObjectContext.save()
        }
        catch let error {
            print("Could not save Deletion \(error)")
        }
        sortList()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryListCell", forIndexPath: indexPath) as! CategoryListCell
                // Configure the cell...
        let cat: Category = self.categoryList[indexPath.row] as! Category
        cell.labelCategoryName.text = cat.title
        
        if cat.color == Constants.COLOR_RED {
            cell.backgroundColor = UIColor.redColor()
        } else if cat.color == Constants.COLOR_ORANGE {
            cell.backgroundColor = UIColor.orangeColor()
        } else if cat.color == Constants.COLOR_YELLOW {
            cell.backgroundColor = UIColor.yellowColor()
        } else if cat.color == Constants.COLOR_GREEN {
            cell.backgroundColor = UIColor.greenColor()
        } else if cat.color == Constants.COLOR_BLUE {
            cell.backgroundColor = UIColor.blueColor()
        } else if cat.color == Constants.COLOR_PURPLE {
            cell.backgroundColor = UIColor.purpleColor()
        } else if cat.color == Constants.COLOR_GREY {
            cell.backgroundColor = UIColor.grayColor()
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
