//
//  MapViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 5/1/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    @IBOutlet weak var mapView: MKMapView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
     //   self.activityView.stopAnimating()
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false;
        locationData()
    }
  
    func addLocationOnMap(location:[[String:Any]])
    {
        let locations = location
        var annotations = [MKPointAnnotation]()
        
        for dictionary in locations {
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            if let lat = dictionary[Student.StudentResponseKey.Latitude] as? Double ,
               let long = dictionary[Student.StudentResponseKey.Longitude] as? Double,
               let first = dictionary[Student.StudentResponseKey.FirstName] as? String,
               let last = dictionary[Student.StudentResponseKey.LastName] as? String,
               let mediaURL = dictionary[Student.StudentResponseKey.MediaUrl] as? String
           {
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude:CLLocationDegrees (lat), longitude: CLLocationDegrees(long))
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation() 
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
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
   
    private func locationData() {
        
       let parameters = ["limit": 100, "order": "-updatedAt"] as [String : AnyObject]
        Client.sharedInstance().taskForGETMethod(parameters: parameters) { (results, error) in
            if let error = error {
                print(error)
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
    
    // MARK: Nav item Actions
    
    // MARK: Refresh Action
    
    @objc func refreshButtonAction() {
       locationData()
    }
    
    // MARK: Add Location
    
    @objc func plusButtonAction() {
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "GetDetailViewController")as! GetDetailViewController
        // Communicate the match
        if let objectId = UserDefaults.standard.string(forKey: Student.StudentResponseKey.ObjectId) {
            
            let msg = "Data already exist, do you want to overwrite"
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.cancel, handler: { (alert: UIAlertAction!) in
                resultVC.objectId = objectId
                self.navigationController?.pushViewController(resultVC, animated: true)
            }))
            present(alert, animated: true, completion: nil)
           
        }
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    // MARK: Logout
    
    @objc func logout() {
      Client.sharedInstance().taskForDELETEMethod() { (results, error) in
                if let error = error {
                    print(error)
                }
                else {
                    if let finalResult = results![Student.StudentParameterKey.Session] as? [String: AnyObject] {
                        if let _ = finalResult[Student.StudentParameterKey.Id] as? String {
                            performUIUpdatesOnMain {
                                UserDefaults.standard.removeObject(forKey: Student.StudentParameterKey.Id)
                                self.dismiss(animated: true, completion: nil)
                                }
                        }
                        
                    }
                }
    }
    }
}
