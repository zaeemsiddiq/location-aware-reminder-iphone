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
    
    let locationManager = CLLocationManager()
    
    var managedObjectContext: NSManagedObjectContext
    var categoryList: NSMutableArray
    var currentCategory: Category?
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        categoryList = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            }
            loadAnnotations()
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func loadAnnotations() {
        for category in (categoryList as NSArray as! [Category]) {
            let location = (name: category.title,
                            coordinate:CLLocationCoordinate2D(latitude: Double(category.location!.latitude!),
                                longitude: Double(category.location!.longitude!)))
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.coordinate = location.coordinate
            mapAnnotation.title = location.name
            mapView.addAnnotation(mapAnnotation)
            
            // Using 1000 metre radius from center of location
            let geofence = CLCircularRegion(center: location.coordinate, radius: 1000, identifier: location.name!)
            locationManager.startMonitoringForRegion(geofence)
        }
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
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
