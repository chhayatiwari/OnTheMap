//
//  LoginViewController.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 4/30/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.string(forKey: Student.StudentParameterKey.Id)) != nil {
           completeLogin()
        }
        else
        {
            self.showUI(bol: true)
        }
    }
    func showUI(bol: Bool) {
        userNameText.isHidden = !bol
        passwordText.isHidden = !bol
        loginButton.isHidden = !bol
        textLabel1.isHidden = !bol
        signUp.isHidden = !bol
        configureUI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    @IBAction func signUp(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        
        if userNameText.text!.isEmpty || passwordText.text!.isEmpty {
            labelView.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            getSessionId()
        }
    }
    
    private func getSessionId() {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\":\"\(userNameText.text ?? "")\", \"password\":\"\(passwordText.text ?? "")\"}}".data(using: .utf8)
        
        let task = appDelegate.sharedSession.dataTask(with: request) { data, response, error in
            
            func displayError(error: String, debugLabelText: String? = nil) {
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.labelView.text = error
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError(error: "Error with Login")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError(error: "Error with the Login Credentials")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError(error: "No data found")
                return
            }
            
            /* 5. Parse the data */
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
           
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            guard let account = parsedResult[Student.StudentParameterKey.Account] as? [String: AnyObject] else {
                displayError(error: "No account found")
                return
            }
            guard let key = account[Student.StudentParameterKey.UniqueId] as? String else {
                displayError(error: "NO key to account")
                return
            }
            guard let session = parsedResult[Student.StudentParameterKey.Session] as? [String: AnyObject] else {
                displayError(error: "No session")
                return
            }
            guard let sessionID = session[Student.StudentParameterKey.Id] as? String else {
                displayError(error: "No session Id")
                return
            }
            UserDefaults.standard.set(sessionID, forKey:Student.StudentParameterKey.Id )
            UserDefaults.standard.set(key, forKey:Student.StudentParameterKey.UniqueId )
            print(UserDefaults.standard.string(forKey: Student.StudentParameterKey.Id)!)
            self.completeLogin()
        }
        task.resume()
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.labelView.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}
// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        userNameText.isEnabled = enabled
        passwordText.isEnabled = enabled
        loginButton.isEnabled = enabled
        labelView.text = ""
        labelView.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
   //     backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(userNameText)
        configureTextField(passwordText)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.delegate = self
        
    }
}
// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
