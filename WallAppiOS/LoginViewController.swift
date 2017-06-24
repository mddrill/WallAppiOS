//
//  LoginRegisterViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    // Controller for login view

    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
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
    
    @IBAction func loginButton(_ sender: UIButton) {
        print("login button pressed")
        accountsClient.login(WithUsername: usernameField.text!, AndPassword: passwordField.text!)
        performSegue(withIdentifier: "LoginToWriteSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToWriteSegue" {
            let writePostViewController = segue.destination as! WritePostViewController
            writePostViewController.postText = writePostText
            writePostViewController.sendPostNow = true
        }
        if segue.identifier == "LoginToRegisterSegue" {
            let registerViewController = segue.destination as! RegisterViewController
            registerViewController.writePostText = self.writePostText
        }
    }
}