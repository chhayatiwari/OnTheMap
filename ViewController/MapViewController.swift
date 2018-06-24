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

    var student:[StudentInformation] = [StudentInformation]()
    var appDelegate: AppDelegate!
    @IBOutlet weak var mapView: MKMapView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false;
        locationData()
    }
  
    private func showLocations(_ locations: [StudentInformation]) {
        mapView.removeAnnotations(mapView.annotations)
        for location in locations where location.lat != nil && location.long != nil {
            let annotation = MKPointAnnotation()
            annotation.title = (location.first == nil ? "" : "\(location.first!) ") + (location.last == nil ? "" : "\(location.last!) ")
            annotation.subtitle = location.mediaURL
            annotation.coordinate = CLLocationCoordinate2DMake(location.lat!, location.long!)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
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
               // app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                if canOpenURL(string: toOpen) {
                    UIApplication.shared.open( URL(string: toOpen)! , options: [:], completionHandler: nil)
                }
                else{
                    showAlert(msg: "URL Invalid")
                }
            }
        }
    }
    
    func canOpenURL(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationData() {
        
       let parameters = ["limit": 100, "order": "-updatedAt"] as [String : AnyObject]
        Client.sharedInstance().taskForGETMethod(parameters: parameters) { (results, error) in
            if let error = error {
               self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
            }
            else {
                if let finalResult = results!["results"] as? [[String: AnyObject]] {
                    self.student = StudentInformation.dataFromResults(finalResult)
                performUIUpdatesOnMain {
                    self.showLocations(self.student)
                    }
                }
        }
        }
    }
    
    @objc func refreshButtonAction() {
       locationData()
    }
   
}
