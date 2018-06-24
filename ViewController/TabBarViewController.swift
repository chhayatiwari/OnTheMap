//
//  TabBarViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 6/10/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    
    @IBAction func refreshAction(_ sender: Any) {
     //   MapViewController.locationData(<#T##MapViewController#>)//locationData()
       var loc = UserManager.shared.locations
        
    }
    
    @IBAction func addLocationAction(_ sender: Any) {
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
    @IBAction func logoutAction(_ sender: Any) {
        Client.sharedInstance().taskForDELETEMethod() { (results, error) in
            if let error = error {
                self.showAlert(msg: error.description)
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
   
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
