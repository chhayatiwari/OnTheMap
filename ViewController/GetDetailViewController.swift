//
//  GetDetailViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 5/3/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit
import CoreLocation

class GetDetailViewController: UIViewController {

    @IBOutlet weak var locationString: UITextField!
    @IBOutlet weak var urlString: UITextField!
    var objectId: String!
    
    @IBOutlet weak var buttonClick: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(startOver))
        self.activityIndicator.stopAnimating()
        configureUI()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        showUI(bol: true)
        
    }
    
   func showUI(bol:Bool ) {
    activityIndicator.isHidden = bol
    buttonClick.isHidden = !bol
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        unsubscribeFromAllNotifications()
    }
    
    @objc func startOver() {
            if let navigationController = navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showInMap(_ sender: Any) {
        if locationString.text!.isEmpty || urlString.text!.isEmpty {
            showAlert(msg: "Empty Data")
        }
        else {
            stringToGeocode()
        }
    }
    
    func stringToGeocode() {
        self.activityIndicator.startAnimating()
        showUI(bol: false)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationString.text!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    self.showAlert(msg: "No location found")
                    self.showUI(bol: true)
                    return
            }
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            UserDefaults.standard.set(lat, forKey: Student.StudentResponseKey.Latitude )
            UserDefaults.standard.set(lon, forKey: Student.StudentResponseKey.Longitude )
                self.getUserDetails()
            }

    }
    
    func getUserDetails() {
        let uniqueId = UserDefaults.standard.string(forKey: Student.StudentParameterKey.UniqueId)
       
        Client.sharedInstance().getUserDetail(uniqueId: uniqueId!) { (results, error) in
            if let error = error {
                self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
                
            }
            else {
            if  let user = results![Student.StudentLocationKey.User] as? [String: AnyObject] {
                let first = user[Student.StudentLocationKey.FirstName] as? String
                let last = user[Student.StudentLocationKey.LastName] as? String
                performUIUpdatesOnMain {
                    if let id = self.objectId  {
                        self.addLocationOverwrite(id: id, first: first!, last: last!)
                    }
                    else {
                        self.addLocation(first: first!, last: last!)
                    }
                }
                }
            }
        }
    }
    
    func addLocation(first: String, last:String) {
        
        let lat = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Latitude)
        let lon = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Longitude)

        Client.sharedInstance().addLocation(id: nil, first: first, last: last, locationString: locationString.text!, urlString: urlString.text!, lat: lat, lon: lon, method: "POST") { (results, error) in
            if let error = error {
                self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
            }
            else {
            if let result = results {
                let id = result[Student.StudentResponseKey.ObjectId] as? String
                let create = result[Student.StudentResponseKey.CreatedAt] as? String
                
                UserDefaults.standard.set(id, forKey: Student.StudentResponseKey.ObjectId )
                performUIUpdatesOnMain {
                    self.findLocation(id: id!, date: create!)
                }
            }
            }
         }
        
    }
    
    func addLocationOverwrite(id: String, first: String, last:String)  {
        
        let lat = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Latitude)
        let lon = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Longitude)
        
        Client.sharedInstance().addLocation(id: id, first: first, last: last, locationString: locationString.text!, urlString: urlString.text!, lat: lat, lon: lon, method: "PUT") { (results, error) in
            if let error = error {
                self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
            }
            else {
            if let result = results {
                let update = result[Student.StudentResponseKey.UpdatedAt] as? String
                performUIUpdatesOnMain {
                    self.findLocation(id: self.objectId, date: update!)
                }
            }
            else{
                self.showAlert(msg: "No data")
                }
            }
        }
    }

    func findLocation(id: String, date: String) {
        self.activityIndicator.stopAnimating()
    let storyboard = UIStoryboard (name: "Main", bundle: nil)
    let resultVC = storyboard.instantiateViewController(withIdentifier: "ShowLocViewController")as! ShowLocViewController
    // Communicate the match
       resultVC.date = date
       self.navigationController?.pushViewController(resultVC, animated: true)
        
    }

}

extension GetDetailViewController: UITextFieldDelegate {
        
        func configureUI() {
            // configure background gradient
            let backgroundGradient = CAGradientLayer()
            backgroundGradient.locations = [0.0, 1.0]
            backgroundGradient.frame = view.frame
            view.layer.insertSublayer(backgroundGradient, at: 0)
            
            configureTextField(locationString)
            configureTextField(urlString)
        }
        
        func configureTextField(_ textField: UITextField) {
            let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
            let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
            textField.leftView = textFieldPaddingView
            textField.leftViewMode = .always
            textField.delegate = self 
        }
        
        func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
        }
        
        func unsubscribeFromAllNotifications() {
            NotificationCenter.default.removeObserver(self)
        }
    
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        }
        
}


