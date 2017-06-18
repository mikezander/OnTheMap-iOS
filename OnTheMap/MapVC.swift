//
//  MapVC.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/10/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        getStudentList()
       
        ParseClient.sharedInstance.getUserData(uniqueKey: User.sharedInstance.uniqueKey!) { (success, error) in
            guard (error == nil) else{ self.errorAlert(title: "Error", message: "Unable to get user data"); return}
            
            if success{
                print("\(User.sharedInstance.firstName) \(User.sharedInstance.lastName)")
            }
        }
    }
    
    func getStudentList(){
        
        ParseClient.sharedInstance.getStudents {(result,error) in
        
            guard (error == nil) else { self.errorAlert(title: "Error", message: "Unable to retrieve list of students"); return}
            
            guard(result != nil) else{ self.errorAlert(title: "Error", message: "Unable to retrieve list of students"); return}

                 ParseClient.sharedInstance.students = result!

            self.performUIUpdatesOnMain {
                self.mapView.addAnnotations(self.populateMap())
                //mapView.removeAnnotations(mapView.annotations)
            }
            
        } //end completion handler
        
    
    }
    
    func populateMap() -> [MKAnnotation]{
    
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for student in ParseClient.sharedInstance.students {
        
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            //let mediaURL = dictionary["mediaURL"] as! String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = student.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        return annotations
        
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        
        getStudentList()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
    
        UdacityClient.sharedInstance().logOutSession(completionHandlerForLogout: {(success, error) in
        
            guard success && error == nil else{ self.errorAlert(title: "Error", message: "Logout failed"); return}
            
            self.performUIUpdatesOnMain {
                self.dismiss(animated: true, completion: nil)
            }
            
        })
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .green
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {
                                                    (success) in
                                                    print("Open \(url): \(success)")
                        })
                    } else {
                        _ = UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
}
