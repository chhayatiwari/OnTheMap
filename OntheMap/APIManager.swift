//
//  APIManager.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 6/13/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import Foundation

class APIManager: NSObject {
    
    func locationData() {
        
        let parameters = ["limit": 100, "order": "-updatedAt"] as [String : AnyObject]
        Client.sharedInstance().taskForGETMethod(parameters: parameters) { (results, error) in
            if let error = error {
              //  self.showAlert(msg: error.userInfo[NSLocalizedDescriptionKey] as! String)
            }
            else {
                if let finalResult = results!["results"] as? [[String: AnyObject]] {
                  //  self.student = StudentInformation.dataFromResults(finalResult)
                    performUIUpdatesOnMain {
                   //     self.showLocations(self.student)
                    }
                }
            }
        }
    }
    
 /*   func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    } */
}
