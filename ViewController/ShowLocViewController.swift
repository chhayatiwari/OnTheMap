//
//  ShowLocViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 5/10/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit
import MapKit

class ShowLocViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var showMap: MKMapView!
    var date: String!
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.locationData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = false
    }
    
    func addLocationOnMap(location:[[String:Any]])
    {
        let locations = location
        var annotations = [MKPointAnnotation]()
        let latDelta: CLLocationDegrees = 0.1
        let lonDelta: CLLocationDegrees = 0.1
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        for dictionary in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            if let lat = dictionary[Student.StudentResponseKey.Latitude],
                let long = dictionary[Student.StudentResponseKey.Longitude]
            {
                let first = dictionary[Student.StudentResponseKey.FirstName] as? String
                let last = dictionary[Student.StudentResponseKey.LastName] as? String
                let mediaURL = dictionary[Student.StudentResponseKey.MediaUrl] as? String
            
                // dictionary[Student.StudentResponseKey.Latitude] as! Double
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude:CLLocationDegrees (lat as! Double), longitude: CLLocationDegrees(long as! Double))
                let region = MKCoordinateRegion(center: coordinate, span: span)
                showMap.setRegion(region, animated: true)
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first!) \(last!)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        }
        self.showMap.addAnnotations(annotations)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
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
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                
            }
        }
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func locationData() {
        
        let parameters = ["where":"{\"\(Student.StudentResponseKey.UniqueKey)\":\"\(Student.Udacity.uniqueKey)\"}"]
        Client.sharedInstance().taskForGETMethod(parameters: parameters as [String : AnyObject]) { (results, error) in
            if let error = error {
                self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
            }
            else {
                if let finalResult = results!["results"] as? [[String: AnyObject]] {
                    performUIUpdatesOnMain {
                        self.addLocationOnMap(location: finalResult)
                    }
                }
            }
        }
    }
    
    
    @IBAction func finish(_ sender: Any) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "MapViewController")as! MapViewController
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
    
}
    
    

