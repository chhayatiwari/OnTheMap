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
    let uniqueKey = "98765"
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
    let bol1 = !bol
    buttonClick.isHidden = bol1
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
            self.stringToGeocode()
        }
    }
    
    func stringToGeocode() {
        self.activityIndicator.startAnimating()
        showUI(bol: false)
       // let address = "1 Infinite Loop, Cupertino, CA 95014"
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationString.text!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    self.showAlert(msg: "No location found")
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
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(uniqueId!)")!)
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
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
                //   print("parsed\(parsedResult)")
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            /* 5. Parse the data */
            
            if  let user = parsedResult[Student.StudentLocationKey.User] as? [String: AnyObject] {
                let first = user[Student.StudentLocationKey.FirstName] as? String
                let last = user[Student.StudentLocationKey.LastName] as? String
                performUIUpdatesOnMain {
                    if let id = self.objectId  {
                        self.addLocationOverwrite(id: id, first: first!, last: last!)
                        
                    }
                    else {
                        self.addLocation(first: first!, last: last!)
                        print("Add Location")
                    }
                    
                }
                
            }
  
        }
        task.resume()
    }
    
    func addLocation(first: String, last:String) {
        
        let lat = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Latitude)
        let lon = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Longitude)

        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(first)\", \"lastName\": \"\(last)\",\"mapString\": \"\(locationString.text!)\", \"mediaURL\": \"\(urlString.text!)\",\"latitude\": \(lat), \"longitude\": \(lon)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
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
            if let result = parsedResult {
              let id = result[Student.StudentResponseKey.ObjectId] as? String
              let create = result[Student.StudentResponseKey.CreatedAt] as? String
                
            UserDefaults.standard.set(id, forKey: Student.StudentResponseKey.ObjectId )
                performUIUpdatesOnMain {
                    self.findLocation(id: id!, date: create!)
                }
            }
        }
        task.resume()
    }
    
    func addLocationOverwrite(id: String, first: String, last:String)  {
        
        let lat = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Latitude)
        let lon = UserDefaults.standard.double(forKey: Student.StudentResponseKey.Longitude)
        let urlStr = "https://parse.udacity.com/parse/classes/StudentLocation/\(id)"
        
        let url = URL(string: urlStr)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(first)\", \"lastName\": \"\(last)\",\"mapString\": \"\(locationString.text!)\", \"mediaURL\": \"\(urlString.text!)\",\"latitude\": \(lat), \"longitude\":\(lon)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
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
            
            if let result = parsedResult {
                let update = result[Student.StudentResponseKey.UpdatedAt] as? String
                performUIUpdatesOnMain {
                    self.findLocation(id: self.objectId, date: update!)
                }
                
            }
        }
        task.resume()
    }

    func findLocation(id: String, date: String) {
        self.activityIndicator.stopAnimating()
        print(date)
    let storyboard = UIStoryboard (name: "Main", bundle: nil)
    let resultVC = storyboard.instantiateViewController(withIdentifier: "ShowLocViewController")as! ShowLocViewController
    // Communicate the match
       resultVC.date = date
       resultVC.uniqueKey = self.uniqueKey
       print(resultVC)
       self.navigationController?.pushViewController(resultVC, animated: true)
        
    }

}

extension GetDetailViewController: UITextFieldDelegate {
        
        func configureUI() {
            // configure background gradient
            let backgroundGradient = CAGradientLayer()
            //     backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
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


