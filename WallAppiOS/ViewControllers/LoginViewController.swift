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
    var sendPostAfter = false
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let username = usernameField.text,
            let password = passwordField.text,
            !username.isEmpty, !password.isEmpty
        else {
            popUpError(withTitle: "Empty Fields",withMessage: "You must enter a username and password")
            return
        }
        accountsClient.login(username: username, password: password,
                             onSuccess: self.handleLoginResponse, onError: self.handleError)
    }
    func handleLoginResponse(token: Token, username: String){
        CurrentUser.username = username
        CurrentUser.token = token.value
        if sendPostAfter {
            self.performSegue(withIdentifier: "LoginToWriteSegue", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "LoginToWallSegue", sender: self)
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
            registerViewController.sendPostAfter = self.sendPostAfter
        }
    }
    
    override func handleError(error: NSError) {
        let statusCode = error.code
        print("Here: \(statusCode)")
        if statusCode == 400 {
            popUpError(withTitle: "Invalid Credentials",withMessage: "Incorrect username or password, please try again")
        }
        else{
            super.handleError(error: error)
        }
    }
}
