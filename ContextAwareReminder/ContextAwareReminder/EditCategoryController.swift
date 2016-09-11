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

class EditCategoryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, addLocationDelegate {
    
    
    var cTitle: String?
    var cDate: NSDate?
    var cRadius: Double?
    var cColor: Int?
    var cNotification: Bool?
    
    var delegate: addCategoryDelegate?
    var managedObjectContext: NSManagedObjectContext
    
    var currentCategory: Category?
    var location: Location?
    var totalCategories: Int = 0
    let locationManager = CLLocationManager()
    @IBOutlet weak var categoryTitle: UITextField!
    @IBOutlet weak var categoryRadius: UITextField!
    //@IBOutlet weak var categoryLocation: MKMapView!
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //categoryLocation.delegate = self
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(EditCategoryController.handleTap(_:)))
        //gestureRecognizer.delegate = self
        //categoryLocation.addGestureRecognizer(gestureRecognizer)
        
        if currentCategory == nil {    // means we are adding a new category, otherwise we are setting a new category
           self.title = "Add Category"
        } else {
            self.title = "Edit Category"
        }
    }
    
    @IBAction func categoryAddButton(sender: AnyObject) {
        // add button tapped, time to make an object and send to list controller so that it can persist it to database and refresh the list by sending object through delegate.
        if(delegate != nil) {
            if currentCategory == nil {
                self.currentCategory = Category.init(entity: NSEntityDescription.entityForName("Category", inManagedObjectContext:
                     self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
            }
            
            if location == nil {
                self.location = Location.init(entity: NSEntityDescription.entityForName("Location", inManagedObjectContext:
                    self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
            }
            currentCategory!.title = categoryTitle.text
            
            location?.latitude = -33.8688
            location?.longitude = 151.2093
            
            currentCategory!.location = location
            currentCategory!.color = 1
            currentCategory!.order = self.totalCategories
            
            print( (currentCategory?.order))
            do {
                try self.managedObjectContext.save()
            }
            catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            
            delegate?.addCategory(currentCategory!)
            self.dismissViewControllerAnimated(true, completion: nil)
            //navigationController?.popViewControllerAnimated(true)   //jump back to the previous screen
        }
        
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func locationSearchButton(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //touch events taken from stackoverflow
    // link: http://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
    
    /*func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.locationInView(categoryLocation)
        let coordinate = categoryLocation.convertPoint(location,toCoordinateFromView: categoryLocation)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        categoryLocation.addAnnotation(annotation)
    }
    
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // Zoom to new user location when updated
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = mapView.userLocation.coordinate
        mapRegion.span = mapView.region.span; // Use current 'zoom'
        mapView.setRegion(mapRegion, animated: true)
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // Only show user location in MapView if user has authorized location tracking
        categoryLocation.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        
        // Notify the user when they have entered a region
        let title = "Entered new region"
        let message = "You have arrived at \(region.identifier)."
        
        if UIApplication.sharedApplication().applicationState == .Active {
            // App is active, show an alert
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // App is inactive, show a notification
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = message
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region \(region.identifier)")
    }
    */
    
    func addLocation(location: Location) {
        self.currentCategory?.location = location
        do {
            try self.managedObjectContext.save()
        }
        catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addLocationSegue" {
            let addLocationSegue:AddLocationController = segue.destinationViewController as! AddLocationController
            addLocationSegue.managedObjectContext = self.managedObjectContext
            addLocationSegue.delegate = self
            
            
        }
    }

}
