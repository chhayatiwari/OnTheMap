//
//  ListViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 5/1/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var appDelegate: AppDelegate!
    var result: [[String: AnyObject]] = []
    @IBOutlet weak var mapViewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.call()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        
        self.navigationItem.rightBarButtonItems = [addButton, refreshButton]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
  //  func call() {
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
                self.result = result
                self.mapViewTable.reloadData()
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
            }
            
        }
        task.resume()
        
    }
    
    // MARK: Nav item Actions
    
    // MARK: Refresh Action
    
    @objc func refreshButtonAction() {
        //   self.activityView.startAnimating()
        // self.showUI(bol: false)
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

// MARK: - ListViewController (UITableViewController)

extension ListViewController {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "StudentDetail"
        let list = result[(indexPath as NSIndexPath).row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?
        if let _ = list[Student.StudentResponseKey.Latitude],
            let _ = list[Student.StudentResponseKey.Longitude],
            let first = list[Student.StudentResponseKey.FirstName] as? String,
            let last = list[Student.StudentResponseKey.LastName] as? String,
            let mediaURL = list[Student.StudentResponseKey.MediaUrl] as? String
        {
        cell?.textLabel!.text = "\(first) \(last)"
        cell?.imageView!.image = UIImage(named: "icon_pin")
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        if let detailTextLabel = cell?.detailTextLabel {
            detailTextLabel.text = "\(mediaURL)"
        }
        }
    
    return cell!
    }
    func canOpenURL(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let list = result[(indexPath as NSIndexPath).row]
       // print(list)
        
        if let urlString = list[Student.StudentResponseKey.MediaUrl] as? String {
            if canOpenURL(string: urlString) {
                UIApplication.shared.open( URL(string: urlString)! , options: [:], completionHandler: nil)
                }
            else{
                showAlert(msg: "URL Invalid")
            }
        }
        else{
            showAlert(msg: "Url not found")
        }
        }
    func showAlert(msg:String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
           self.present(alert, animated: true, completion: nil)
    }
}



