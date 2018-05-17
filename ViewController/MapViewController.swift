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
   // @IBOutlet var activityView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        
        self.navigationItem.rightBarButtonItems = [addButton, refreshButton]
     //   self.activityView.stopAnimating()
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false;
        self.locationData()
      //  self.showUI(bol: true)
    }
    
 /*   func showUI(bol: Bool) {
        self.activityView.isHidden = bol
      //  self.mapView.isHidden = !bol
    } */
    
    func addLocationOnMap(location:[[String:Any]])
    {
        let locations = location
        var annotations = [MKPointAnnotation]()
        
        for dictionary in locations {
            print(dictionary)
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            if let lat = dictionary[Student.StudentResponseKey.Latitude] as? Double ,
               let long = dictionary[Student.StudentResponseKey.Longitude] as? Double,
               let first = dictionary[Student.StudentResponseKey.FirstName] as? String,
               let last = dictionary[Student.StudentResponseKey.LastName] as? String,
               let mediaURL = dictionary[Student.StudentResponseKey.MediaUrl] as? String
           {
           // dictionary[Student.StudentResponseKey.Latitude] as! Double
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
        self.mapView.addAnnotations(annotations)
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
        
        let url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
           
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
             //   print("parsed\(parsedResult)")
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
           let result = (parsedResult["results"] as? [[String: AnyObject]])!
            performUIUpdatesOnMain {
                self.addLocationOnMap(location: result)
            }
           
        }
        task.resume()
    }
   
    
    // MARK: Nav item Actions
    
    // MARK: Refresh Actio
    
    @objc func refreshButtonAction() {
        viewWillAppear(true)
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
            //   self.present(alert, animated: true, completion: nil)
            self.present(alert, animated: true) {
                print(objectId)
            }
            
        }
        self.navigationController?.pushViewController(resultVC, animated: true)
  /*      performUIUpdatesOnMain {
            self.activityView.startAnimating()
            self.showUI(bol: false)
        } */
    }
    
    // MARK: Logout
    
    @objc func logout() {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 {
                UserDefaults.standard.removeObject(forKey: Student.StudentParameterKey.Id)
                self.dismiss(animated: true, completion: nil)
                
            }
            else {
                print("Your request returned a status code other than 2xx!")
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print(String(data: newData, encoding: .utf8)!)
         /*   performUIUpdatesOnMain {
                self.activityView.startAnimating()
                self.showUI(bol: false)
            } */
           
        }
        task.resume()
    }
    
}
