//
//  LocationAttachmentViewController.swift
//  Notes
//
//  Created by Jonathon Manning on 27/08/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import UIKit

// BEGIN mapkit_frameworks
import MapKit
import CoreLocation
// END mapkit_frameworks

// BEGIN map_default_coordinate
let defaultCoordinate =
    CLLocationCoordinate2D(latitude: -42.882743, longitude: 147.330234)
// END map_default_coordinate

// BEGIN map_protocols
class LocationAttachmentViewController: UIViewController,
    AttachmentViewer, MKMapViewDelegate {
// END map_protocols
    
    
    // BEGIN mapview_property
    @IBOutlet weak var mapView : MKMapView?
    // END mapview_property
    
    // BEGIN attachment_protocol_compliance
    var attachmentFile : FileWrapper?
    
    var document : Document?
    // END attachment_protocol_compliance
    
    
    @IBOutlet weak var showCurrentLocationButton: UIBarButtonItem?
    
    // BEGIN location_pins
    let locationManager = CLLocationManager()
    
    let locationPinAnnotation = MKPointAnnotation()
    // END location_pins
    
    // BEGIN view_will_appear_location
    override func viewWillAppear(_ animated: Bool) {
        
        locationPinAnnotation.title = "Drag to place"
        
        // Start by assuming that we can't show the location
        self.showCurrentLocationButton?.isEnabled = false
        
        if let data = attachmentFile?.regularFileContents {
            
            do {
                guard let loadedData =
                    try JSONSerialization.jsonObject(with: data,
                        options: JSONSerialization.ReadingOptions())
                        as? [String:CLLocationDegrees] else {
                    return
                }
                
                if let latitude = loadedData["lat"],
                    let longitude = loadedData["long"] {
                    
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude,
                                                            longitude: longitude)
                    
                    locationPinAnnotation.coordinate = coordinate
                    
                    self.mapView?.addAnnotation(locationPinAnnotation)
                }
                
            } catch let error as NSError {
                NSLog("Failed to load location: \(error)")
            }
            
            // Make the Done button save the attachment
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                target: self, action: #selector(LocationAttachmentViewController.addAttachmentAndClose))
            self.navigationItem.rightBarButtonItem = doneButton
            
            
        } else {
            // Set up for editing: create a 'cancel' button that 
            // dismisses the view
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                target: self, action: #selector(LocationAttachmentViewController.closeAttachmentWithoutSaving))
            self.navigationItem.leftBarButtonItem = cancelButton
            
            // Now add the Done button that adds the attachment
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                target: self, action: #selector(LocationAttachmentViewController.addAttachmentAndClose))
            self.navigationItem.rightBarButtonItem = doneButton
            
            // Get notified about the user's location; we'll use
            // this to add the pin when
            self.mapView?.delegate = self
            
            
        }
    }
    // END view_will_appear_location
    
    // BEGIN location_view_did_load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
    }
    // END location_view_did_load
    
    // BEGIN location_mapview_didupdatelocation
    func mapView(_ mapView: MKMapView,
        didUpdate userLocation: MKUserLocation) {
        
        
        // If we know the user's location, we can zoom to it
        self.showCurrentLocationButton?.isEnabled = true
        
        // We know the user's location - add the pin!
        
        if self.pinIsVisible == false {
            let coordinate = userLocation.coordinate
            
            locationPinAnnotation.coordinate = coordinate
            self.mapView?.addAnnotation(locationPinAnnotation)
            
            self.mapView?.selectAnnotation(locationPinAnnotation,
                animated: true)
        }
    }
    // END location_mapview_didupdatelocation
    
    // BEGIN location_mapview_didfailtolocate
    func mapView(_ mapView: MKMapView,
         didFailToLocateUserWithError error: Error) {
        
        NSLog("Failed to get user location: \(error)")
        
        // We can't show the current location
        self.showCurrentLocationButton?.isEnabled = false
        
        // Add the pin, but fall back to the default location
        if self.pinIsVisible == false {
            locationPinAnnotation.coordinate = defaultCoordinate
            self.mapView?.addAnnotation(locationPinAnnotation)
        }
    }
    // END location_mapview_didfailtolocate
    
    // BEGIN location_mapview_viewforannotation
    func mapView(_ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "Location"
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            
            if let existingAnnotation = self.mapView?
                .dequeueReusableAnnotationView(withIdentifier: reuseID) {
                    
                existingAnnotation.annotation = annotation
                return existingAnnotation
            } else {
                
                let annotationView =
                    MKPinAnnotationView(annotation: pointAnnotation,
                        reuseIdentifier: reuseID)
                
                annotationView.isDraggable = true
                
                annotationView.canShowCallout = true
                
                return annotationView
            }
            
        } else {
            return nil
        }
        
    }
    // END location_mapview_viewforannotation
    
    // BEGIN location_mapview_pinisvisible
    var pinIsVisible : Bool {
        return self.mapView!.annotations.contains(where: { (annotation) -> Bool in
            return annotation is MKPointAnnotation
        })
    }
    // END location_mapview_pinisvisible
    
    // BEGIN location_add_attachment_and_close
    func addAttachmentAndClose() {
        
        if self.pinIsVisible {
            
            let location = self.locationPinAnnotation.coordinate
            
            // Convert the location into a dictionary
            let locationDict : [String:CLLocationDegrees] =
            [
                "lat":location.latitude,
                "long":location.longitude
            ]
            
            do {
                let locationData = try JSONSerialization
                    .data(withJSONObject: locationDict,
                        options: JSONSerialization.WritingOptions())

                let locationName : String
                
                let newFileName = "\(arc4random()).json"
                
                if attachmentFile != nil {
                    
                    locationName
                        = attachmentFile!.preferredFilename ?? newFileName
                    
                    try self.document?.deleteAttachment(self.attachmentFile!)
                } else {
                    locationName = newFileName
                }
                
                try self.document?.addAttachmentWithData(locationData,
                    name: locationName)
            
                
            } catch let error as NSError {
                NSLog("Failed to save location: \(error)")
            }
        }
        
        self.presentingViewController?.dismiss(animated: true,
            completion: nil)
    }
    // END location_add_attachment_and_close
    
    
    // BEGIN location_close_attachment
    func closeAttachmentWithoutSaving() {
        self.presentingViewController?.dismiss(animated: true,
            completion: nil)
    }
    // END location_close_attachment
    

    // BEGIN show_current_location
    @IBAction func showCurrentLocation(_ sender: AnyObject) {
        
        // This will zoom to the current location
        self.mapView?.setUserTrackingMode(.follow, animated: true)
        
    }
    // END show_current_location
    
    
}
