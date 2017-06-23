//
//  RegisterViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    // Controller for register account view
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reenterPaswordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    let accountsClient = AccountsServiceClient.sharedInstance
    
    var writePostText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IMPORTANT: This code allows me to test this app on my local machine by turning off certificate
        // checking, I understand that it is not secure and would not put this code in production
        accountsClient.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: trust)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = self.accountsClient.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        print("registerButton called")
        guard passwordField.text! == reenterPaswordField.text! else {
            print("passwords don't match")
            let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard (emailField.text?.isValidEmail())! else {
            print("email is invalid")
            let alert = UIAlertController(title: "Error", message: "Email is not valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let username = usernameField.text!
        let password = passwordField.text!
        let email = emailField.text!
        accountsClient.register(User: username, WithPassword: password, AndEmail: email) { response in
            if let error = response.result.error {
                let alert = UIAlertController(title: "Error", message: "Could not register: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.accountsClient.login(WithUsername: username, AndPassword: password)
            self.performSegue(withIdentifier: "RegisterToWriteSegue", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterToWriteSegue" {
            let writePostViewController = segue.destination as! WritePostViewController
            writePostViewController.postText = writePostText
            writePostViewController.sendPostNow = true
        }
        if segue.identifier == "RegisterToLoginSegue" {
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.writePostText = writePostText
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
