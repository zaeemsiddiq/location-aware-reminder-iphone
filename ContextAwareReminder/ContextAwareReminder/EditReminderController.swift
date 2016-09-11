//
//  EditReminderController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/9/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData

class EditReminderController: UIViewController {

    @IBOutlet weak var reminderTitleText: UITextField!
    @IBOutlet weak var reminderNoteText: UITextView!
    @IBOutlet weak var reminderDateText: UIDatePicker!
    var isvalid: Bool = false
    
    var delegate: ItemsListController?
    var currentReminder: Reminder?
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false  // as it overlaps its children navigation bars thats y i had to programatically hide it
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentReminder == nil {    // means we are adding a new reminder, otherwise we are setting a new reminder
            self.title = "Add Reminder"
        } else {
            self.title = "View Reminder"
            reminderTitleText.text = currentReminder?.title
            reminderNoteText.text = currentReminder?.note
            if let unwrappedDate = currentReminder?.datetime! {
                reminderDateText.setDate(unwrappedDate, animated: false)
            }
        }
        
        if currentReminder == nil {
                self.currentReminder = Reminder.init(entity: NSEntityDescription.entityForName("Reminder", inManagedObjectContext:
                    self.managedObjectContext!)!, insertIntoManagedObjectContext: self.managedObjectContext)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonDone(sender: AnyObject) {
        
        currentReminder?.title = reminderTitleText.text
        currentReminder?.note = reminderNoteText.text
        currentReminder?.datetime = reminderDateText.date
        currentReminder?.status = 0
        delegate?.addReminder(currentReminder!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isValid() -> Bool {
        var title: String? = "Error"
        var errorMessage: String? = "Following fileds are required \n"
        isvalid = true
        if ((reminderTitleText.text?.isEmpty) != nil) {
            
        } else {
            errorMessage = "Title"
            isvalid=false
        }
        
        return isvalid
    }

    @IBAction func buttonCancel(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
