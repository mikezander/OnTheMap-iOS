//
//  LocationDetailVC.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/13/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailVC: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
 
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
   

    var mapString :String!
    var mediaUrl: String!
    var pointAnnotation: MKPointAnnotation!
    
    let whereString = "Where are you\r studying\r today?" as NSString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        linkTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        performUIUpdatesOnMain {
            self.linkTextField.isEnabled = false
            self.mapView.isHidden = true
            
            self.findButton.layer.cornerRadius = 10
            self.findButton.clipsToBounds = true
            self.whereLabel?.attributedText = self.attributedBoldText(string: self.whereString,
                                                            boldString: "studying",
                                                            fontSize: 26)
            self.whereLabel.sizeToFit()
        }
  
    }
  
    @IBAction func findOnMapPressed(_ sender: Any) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start(completionHandler: {(localSearchResponse, error) in
            guard(error == nil) else{ self.errorAlert(title: "Error", message: "Unable to retrieve location"); return}
            
            guard(localSearchResponse != nil) else{ self.errorAlert(title: "Error", message: "Unable to retrieve location"); return}
            
        self.mapString = self.locationTextField.text
            
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.title = self.locationTextField.text
        self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(localSearchResponse!.boundingRegion.center.latitude, localSearchResponse!.boundingRegion.center.longitude)
       
        let pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 5000, 5000)
       
            
            performUIUpdatesOnMain {
                
                //hide top view
                self.secondView.isHidden = true
                
                self.linkTextField.isHidden = false
                self.linkTextField.isEnabled = true
                self.mapView.isHidden = false
                
                
                self.cancelButton.setTitleColor(UIColor.white, for: .normal)
                self.view.addSubview(self.cancelButton)
                
                //post location button(programatically)
                let postLocationButton = self.configButton()
                postLocationButton.addTarget(self, action:#selector(self.postLocationPressed), for: .touchUpInside)
                self.view.addSubview(postLocationButton)
            }
    
        })//end completion handler

    }
    
    func postLocationPressed(sender: UIButton!) {
        
        mediaUrl = linkTextField.text
        ParseClient.sharedInstance.postLocation(mapString: mapString, mediaUrl: mediaUrl, pointAnnotation: pointAnnotation, completionHandlerForPostLocation: {(success, error) in
            guard(error == nil) else{ self.errorAlert(title: "Error", message: "Unable to post location"); return}
            
            if success{
               //successfully posted location!
                self.dismiss(animated: true, completion: nil)
            }
            
        })//end completion handler
    
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // configuration for post location button
    func configButton()-> UIButton{
        let btn = UIButton()
        btn.setTitle("Submit", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = UIColor.white
        btn.frame = CGRect(x: self.view.frame.width/2 - 50, y: self.view.frame.height/2 + 225, width: 100, height: 36)
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.isEnabled = true
        return btn
    }
    
    func attributedBoldText(string: NSString, boldString: String, fontSize: CGFloat)->NSAttributedString{
 
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: boldString))
        
        return attributedString
    }
    
    func errorAlert(title:String, message:String){
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

extension LocationDetailVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
}
