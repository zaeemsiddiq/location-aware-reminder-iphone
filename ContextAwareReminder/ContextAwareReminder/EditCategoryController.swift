//
//  EditCategoryController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class EditCategoryController: UIViewController, addLocationDelegate {
    
    var delegate: addCategoryDelegate?
    var managedObjectContext: NSManagedObjectContext
    
    var currentCategory: Category?  // holds the current category if their is any set
    var location: Location? // holds the current location if their is any set
    var totalCategories: Int = 0    // used to set the indexes
    var currentOrder: Int = 0
    var currentColor: Int = 1
    var currentRadius: Int = 250
    
    var isvalid: Bool = false   // used to decide if the entries are valid or not
    
    @IBOutlet weak var categoryTitle: UITextField!
    
    @IBAction func radiusChanged(sender: AnyObject) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.currentRadius = 250
        case 1:
           self.currentRadius = 500
        case 2:
            self.currentRadius = 1000
        default:
            print("Unexpected segment index for map type.")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentCategory == nil {
            self.title = "Add Category"
            self.currentCategory = Category.init(entity: NSEntityDescription.entityForName("Category", inManagedObjectContext:
                self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
            currentOrder = totalCategories
        } else {    // var has been set which means we are editing the currentCategory
            self.title = "Edit Category"
            currentOrder = self.currentCategory?.order as! Int
            populateFields()
        }
        
        if location == nil {
            self.location = Location.init(entity: NSEntityDescription.entityForName("Location", inManagedObjectContext:
                self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
        }
    }
    
    func populateFields() {
        categoryTitle.text = self.currentCategory?.title
        currentColor = self.currentCategory?.color as! Int
        self.location = self.currentCategory?.location
    }
    @IBAction func categoryAddButton(sender: AnyObject) {
        // add button tapped, time to make an object and send to list controller so that it can persist it to database and refresh the list by sending object through delegate.
        if(delegate != nil) {
            if isValid() {
                currentCategory!.title = categoryTitle.text
                currentCategory?.location?.radius = currentRadius
                currentCategory!.location = self.location
                currentCategory!.color = currentColor
                currentCategory!.order = currentOrder
                do {
                    try self.managedObjectContext.save()
                }
                catch {
                    let fetchError = error as NSError
                    print(fetchError)
                }
                
                delegate?.addCategory(currentCategory!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // check if the fields are valid are not, if not display the valid messages as alert notification
    func isValid() -> Bool {
        let title = "Error"
        var errorMessage = "Following fileds are required \n"
        isvalid = true  // assuming that the form is valid in the first place
        if categoryTitle.text == "" {
            errorMessage += "Title"
            isvalid=false
        }
        if currentColor == 0 {
            errorMessage += "Color"
            isvalid=false
        }
        
        if (!isvalid) {
            let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        return isvalid
    }
    
    // setting the colors
    @IBAction func buttonRed(sender: AnyObject) {
        currentColor = Constants.COLOR_RED
    }
    @IBAction func buttonOrange(sender: AnyObject) {
         currentColor = Constants.COLOR_ORANGE
    }
    
    @IBAction func buttonGreen(sender: AnyObject) {
         currentColor = Constants.COLOR_GREEN
    }
    @IBAction func buttonYellow(sender: AnyObject) {
         currentColor = Constants.COLOR_YELLOW
    }
    @IBAction func buttonBlue(sender: AnyObject) {
         currentColor = Constants.COLOR_BLUE
    }
    @IBAction func buttonPurple(sender: AnyObject) {
         currentColor = Constants.COLOR_PURPLE
    }
    @IBAction func buttonGray(sender: AnyObject) {
         currentColor = Constants.COLOR_GREY
    }
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func locationSearchButton(sender: AnyObject) {
    }
    
    // catching the setted location from addlocation view
    func addLocation(location: Location) {
        self.location = location
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addLocationSegue" {
            let addLocationSegue:AddLocationController = segue.destinationViewController as! AddLocationController
            addLocationSegue.managedObjectContext = self.managedObjectContext
            addLocationSegue.location = self.location!
            addLocationSegue.delegate = self
            
        }
    }

}
