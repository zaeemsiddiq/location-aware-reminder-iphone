//
//  EditCategoryController.swift
//  ContextAwareReminder
//
//  Created by Zaeem Siddiq on 9/7/16.
//  Copyright © 2016 Zaeem Siddiq. All rights reserved.
//

import UIKit
import MapKit

class EditCategoryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var categoryTitle: UITextField!
    @IBOutlet weak var categoryRadius: UITextField!
    @IBOutlet weak var categoryLocation: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryLocation.delegate = self
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func categoryAddButton(sender: AnyObject) {
    }

    @IBAction func cancelButon(sender: AnyObject) {
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
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.locationInView(categoryLocation)
        let coordinate = categoryLocation.convertPoint(location,toCoordinateFromView: categoryLocation)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        categoryLocation.addAnnotation(annotation)
    }

}
