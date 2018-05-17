//
//  CustomNavController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 5/12/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit

class CustomNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        
        self.navigationItem.rightBarButtonItems = [addButton, refreshButton]
        
    }
    // MARK: Nav item Actions
    
    // MARK: Refresh Actio
    
    @objc func refreshButtonAction() {
        print("refresh")
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
            
            /*    if sessionID == (UserDefaults.standard.string(forKey: Student.StudentParameterKey.Id)) {
             print("hello\(sessionID)")
             } */
        }
        task.resume()
    }
    
   
}
