//
//  LoginRegisterViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: BaseViewController {
        
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var writePostText : String!
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let username = usernameField.text,
            let password = passwordField.text
        else {
            print("Incorrect Username or Password")
            popUpError(withMessage: "You must enter a username and password")
            return
        }
        accountsClient.login(username: username, password: password) { response in
            if let error = response.result.error {
                print("There were errors logging in")
                self.handle(requestError: error)
            }
            else {
                self.performSegue(withIdentifier: "LoginToWriteSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToWriteSegue" {
            print("LoginToWriteSegue")
            let writePostViewController = segue.destination as! WritePostViewController
            writePostViewController.postText = writePostText
            writePostViewController.sendPostNow = true
        }
        if segue.identifier == "LoginToRegisterSegue" {
            print("LoginToRegisterSegue")
            let registerViewController = segue.destination as! RegisterViewController
            registerViewController.writePostText = self.writePostText
        }
    }
    
    override func handle(requestError error: Error) {
        if (error as? AFError) != nil && (error as? AFError)?.responseCode == 400 {
            popUpError(withMessage: "Incorrect Username or Password!")
        }
        else{
            super.handle(requestError: error)
        }
    }
}
