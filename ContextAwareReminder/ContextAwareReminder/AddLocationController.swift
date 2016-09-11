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

class AddLocationController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {

    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var locationName: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var location: Location?
    var currentCategory: Category?
    var managedObjectContext: NSManagedObjectContext
    var annotationAdded: Bool = false
    
    var delegate: EditCategoryController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegation so we can respond to MapView and LocationManager events
        mapView.delegate = self
        locationName.delegate = self
        
        if(self.location == nil) {
            self.location = Location.init(entity: NSEntityDescription.entityForName("Location", inManagedObjectContext:
                self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
        } else {
            populateForm()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }
    func populateForm() {
        if location?.notify == 1 {
            reminderSwitch.setOn(true, animated: true)
        } else {
            reminderSwitch.setOn(false, animated: true)
        }
        if location?.address != "" {
            locationName.text = location?.address
        }
        if location != nil {
            let location = (name: self.location?.name,
                            coordinate:CLLocationCoordinate2D(latitude: Double(self.location!.latitude!),
                                longitude: Double(self.location!.longitude!)))
            let mapAnnotation = MKPointAnnotation()
            mapAnnotation.title = self.location?.name
            mapAnnotation.coordinate = location.coordinate
            mapAnnotation.title = location.name
            mapView.addAnnotation(mapAnnotation)
        }
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
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
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonDone(sender: AnyObject) {
        if self.reminderSwitch.on {
            self.location?.notify = 1
        } else {
            self.location?.notify = 0
        }
        self.delegate?.addLocation(self.location!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonCancel(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
