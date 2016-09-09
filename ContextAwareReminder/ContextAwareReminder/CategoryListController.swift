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
    
    required init?(coder aDecoder: NSCoder) {
        categoryList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.editing = !self.editing
    }
    @IBAction func addCategoryButton(sender: AnyObject) {
        //self.performSegueWithIdentifier("editCategorySegue", sender:self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        //self.editing = true
        loadData()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryListCell", forIndexPath: indexPath) as! CategoryListCell
                // Configure the cell...
        let cat: Category = self.categoryList[indexPath.row] as! Category
        cell.labelCategoryName.text = cat.title
        if(cat.color == Constants.COLOR_GREY) {
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
        if segue.identifier == "addCategorySegue" {
            let editCategorySegue:EditCategoryController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! EditCategoryController
            editCategorySegue.delegate = self
            editCategorySegue.managedObjectContext = self.managedObjectContext
        }
        if segue.identifier == "viewCategorySegue" {
            let itemsListSegue:ItemsListController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ItemsListController
            if let selectedReminderCell = sender as? CategoryListCell {
                let indexPath = tableView.indexPathForCell(selectedReminderCell)!
                itemsListSegue.currentCategory = self.categoryList.objectAtIndex(indexPath.row) as? Category
            }
           
        }
    }
    

}
