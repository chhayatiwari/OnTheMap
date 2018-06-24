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
        Client.sharedInstance().taskForPOSTMethod(userName: userNameText.text!, passwordText: passwordText.text!) { (results, error) in
            
            func displayError(errormsg: String, debugLabelText: String? = nil) {
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.labelView.text = errormsg
                }
            }
            if let errors = error {
                displayError(errormsg: errors.userInfo[NSLocalizedDescriptionKey] as! String )
                return
            }
            guard let account = results![Student.StudentParameterKey.Account] as? [String: AnyObject] else {
                displayError(errormsg: "No account found")
                return
            }
            guard let key = account[Student.StudentParameterKey.UniqueId] as? String else {
                displayError(errormsg: "No key to account")
                return
            }
            guard let session = results![Student.StudentParameterKey.Session] as? [String: AnyObject] else {
                displayError(errormsg: "No session")
                return
            }
            guard let sessionID = session[Student.StudentParameterKey.Id] as? String else {
                displayError(errormsg: "No session Id")
                return
            }
            UserDefaults.standard.set(sessionID, forKey:Student.StudentParameterKey.Id )
            UserDefaults.standard.set(key, forKey:Student.StudentParameterKey.UniqueId )
            print(UserDefaults.standard.string(forKey: Student.StudentParameterKey.Id)!)
            self.completeLogin()
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.labelView.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginNavViewController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
           // self.navigationController?.pushViewController(controller, animated: true)
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
