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
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        mapView.delegate = self // listening passing self object so that mapview can talk to its delegates which are implemented in this controller
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    // this method itereates through all the loaded categories and adds annotations onto the map
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
                
                circle = MKCircle(centerCoordinate: location.coordinate, radius: Double (category.location!.radius!) )
                self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
                self.mapView.addOverlay(circle)
                
                // Using 1000 metre radius from center of location
                let geofence = CLCircularRegion(center: location.coordinate, radius: 1000, identifier: location.name!)
                locationManager.startMonitoringForRegion(geofence)
            }
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blueColor()
        circleRenderer.lineWidth = 1
        return circleRenderer
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
