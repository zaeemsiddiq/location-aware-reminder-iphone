//
//  AddLocationController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/9/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AddLocationController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{

    var location: Location?
    var managedObjectContext: NSManagedObjectContext
    var annotationAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(self.location == nil) {
            self.location = Location.init(entity: NSEntityDescription.entityForName("Location", inManagedObjectContext:
                self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.managedObjectContext = NSManagedObjectContext()
        super.init(coder: aDecoder)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonDone(sender: AnyObject) {
        
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
