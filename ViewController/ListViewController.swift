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
     var student:[StudentInformation] = [StudentInformation]()
    @IBOutlet weak var mapViewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        toGetData()
    }
    
    func toGetData() {
     
        let parameters = ["limit": 100, "order": "-updatedAt"] as [String : AnyObject]
        Client.sharedInstance().taskForGETMethod(parameters: parameters) { (results, error) in
            if let error = error {
                print(error)
            }
            else {
                if let finalResult = results!["results"] as? [[String: AnyObject]] {
                    self.student = StudentInformation.dataFromResults(finalResult)
                    performUIUpdatesOnMain {
                        self.result = finalResult
                        self.mapViewTable.reloadData()
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                    }
                  }
               }
         }
    }
}

// MARK: - ListViewController (UITableViewController)

extension ListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "StudentDetail"
        let list = student[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?
        if let detailTextLabel = cell?.detailTextLabel,
            let media = list.mediaURL {
        if let f = list.first,
            let l = list.last {
        cell?.textLabel!.text = "\(f) \(l)"
        cell?.imageView!.image = UIImage(named: "icon_pin")
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
             detailTextLabel.text = media
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
         let list = student[(indexPath as NSIndexPath).row]
        
        if let media = list.mediaURL{
            if canOpenURL(string: media) {
                UIApplication.shared.open( URL(string: media)! , options: [:], completionHandler: nil)
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
        present(alert, animated: true, completion: nil)
    }
}



