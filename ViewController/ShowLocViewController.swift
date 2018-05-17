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
    var uniqueKey: String!
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
    
    private func locationData() {
        
        let methodParameters = ["where":"{\"\(Student.StudentResponseKey.UniqueKey)\":\"\(self.uniqueKey!)\"}"]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: ""))
       // let url = URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
       //var request = URLRequest(url: url)
        print(request)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            
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
    
    
    @IBAction func finish(_ sender: Any) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "MapViewController")as! MapViewController
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
    
}
    
    

