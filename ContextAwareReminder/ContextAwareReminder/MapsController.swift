//
//  MapsController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/8/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapsController:UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var circle:MKCircle!
    
    let locationManager = CLLocationManager()
    
    var managedObjectContext: NSManagedObjectContext
    var categoryList: NSMutableArray
    var currentCategory: Category?
    @IBOutlet weak var mapView: MKMapView!
    var remindersList: NSMutableArray
    
    
    override func viewDidLoad() {        

        super.viewDidLoad()
        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        remindersList = NSMutableArray()
        categoryList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    
    
    // this method loads the category list from core date and saves into local category list array
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
            }
            loadAnnotations()
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    // this method itereates through all the loaded categories and adds annotations onto the map, moreover, while adding annotations to the map, it also adds a button the annotation which fires an event written below so that we can jump to the items list controller
    
    func loadAnnotations() {
        for category in (categoryList as NSArray as! [Category]) {
            if category.location != nil { // checking if the location is not nil
                let location = (name: category.title,
                                coordinate:CLLocationCoordinate2D(latitude: Double(category.location!.latitude!),
                                    longitude: Double(category.location!.longitude!)))
                let mapAnnotation = MKPointAnnotation()
                mapAnnotation.title = category.title
                mapAnnotation.coordinate = location.coordinate
                mapAnnotation.title = location.name
                
            
                mapView.addAnnotation(mapAnnotation)
                
                // drawing the radius circle around the annotation
                circle = MKCircle(centerCoordinate: location.coordinate, radius: Double (category.location!.radius!) )
                self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
                self.mapView.addOverlay(circle)
                
                // assigning geofencing if the user has enabled it
                print ("notify \(category.location?.notify) - \(category.location!.radius!)")
                if category.location?.notify == 1 {
                    let geofence = CLCircularRegion(center: location.coordinate, radius: Double (1000), identifier: location.name!)
                    locationManager.startMonitoringForRegion(geofence)
                }
            }
        }
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
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    
    // this method gets fired when the uer presses the button in the info window
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control == view.rightCalloutAccessoryView)
        {
            let selectedTitle = view.annotation!.title!
            for category in categoryList
            {
                let eachCategory = category as! Category
                if(eachCategory.title! == selectedTitle!)
                {
                    self.currentCategory = eachCategory
                }
            }
            // jump to the view reminders controller
            performSegueWithIdentifier("viewCategorySegue", sender: self)
        }
    }
    
    // rendering the pin on runtime, this code has been taken from http://stackoverflow.com/questions/37964914/show-annotation-title-and-subtitle-in-custom-mkpinannotationview
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            view?.annotation = annotation
        }
        return view
    }
    
    // drawing a circle for annotation, which shows the radius of the location, code has been taken from the following link http://sweettutos.com/2015/12/06/swift-mapkit-tutorial-series-how-to-make-a-map-based-overlays/
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blueColor()
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    
    
    // check if there are any pending notifications for that category, returns true or false
    func anyPendingNotifications(categoryName: String) -> Bool {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Category", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "title = %@", (categoryName))
        fetchRequest.entity = entityDescription
        var result = NSArray?()
        var anyPending = false
        do
        {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            
            if result!.count > 0
            {
                let cat: Category = (result?.objectAtIndex(0) as? Category)!
                remindersList = NSMutableArray(array: (cat.reminders?.allObjects as! [Reminder]))
            }
        
            
            for reminder in (remindersList as NSArray as! [Reminder]) {
                if reminder.status == 0 {
                    anyPending = true
                }
            }
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
    
        return anyPending == true ? true : false
    }
    
    // when the user enters a region it generates the notifications, if the notification was set to ON
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        
        // Notify the user when they have entered a region
        let title = "Reminder Notification"
        let message = "You have arrived at \(region.identifier). and have got pending items in the category"
        
        if anyPendingNotifications(region.identifier) {
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
        
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Notify the user when they have entered a region
        let title = "Reminder Notification"
        let message = "You are about to leave \(region.identifier). Did you collect your stuff ?"
        
        if anyPendingNotifications(region.identifier) {
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
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "viewCategorySegue" {
            let itemsListSegue:ItemsListController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ItemsListController
             itemsListSegue.currentCategory = self.currentCategory            
        }
    }
}
