//
//  AddLocationController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/9/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

class AddLocationController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var locationName: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var location: Location?
    var managedObjectContext: NSManagedObjectContext
    var annotationAdded: Bool = false
    
    var delegate: EditCategoryController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        
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
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        // converting address to lat long cordinates
        //http://stackoverflow.com/questions/24706885/how-can-i-plot-addresses-in-swift-converting-address-to-longitude-and-latitude
        let address = locationName.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil) { 
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                let mapAnnotation = MKPointAnnotation()
                mapAnnotation.coordinate = coordinates
                self.mapView.addAnnotation(mapAnnotation)
                
                self.location?.latitude = coordinates.latitude
                self.location?.longitude = coordinates.longitude
                self.location?.name = placemark.name
                self.location?.address = self.locationName.text
                if self.reminderSwitch.on {
                    self.location?.notify = 1
                } else {
                    self.location?.notify = 0
                }
                self.delegate?.addLocation(self.location!)
            }
        })
    }
}
