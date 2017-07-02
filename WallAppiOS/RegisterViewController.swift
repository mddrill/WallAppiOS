//
//  RegisterViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: BaseViewController {
    
    // Controller for register account view
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reenterPaswordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var writePostText : String!
    
    @IBAction func registerButton(_ sender: UIButton) {
        guard let username = usernameField.text,
            let password1 = passwordField.text,
            let password2 = reenterPaswordField.text,
            let email = emailField.text,
            !username.isEmpty, !password1.isEmpty, !password2.isEmpty, !email.isEmpty
        else {
            popUpError(withTitle: "Empty Fields", withMessage: "Must enter all fields")
            return
        }
        do{
            try accountsClient
                .register(username: username,
                          password1: password1,
                          password2: password2,
                          email: email){ response in
                            if let error = response.result.error {
                                self.handle(error: error as NSError)
                            }
                            else {
                                self.accountsClient
                                    .login(username: username,
                                           password: password1,
                                           onSuccess: self.handleLoginResponse,
                                           onError: self.handle)
                            }
                          }
        }
        catch RegistrationError.emailIsInvalid {
            popUpError(withTitle: "Invalid Email", withMessage: "Must enter a valid email")
        }
        catch RegistrationError.passwordsDontMatch {
            popUpError(withTitle: "Passwords don't match", withMessage: "Passwords must match")
        }
        catch {
            popUpError(withTitle: "Unkown Registration Error", withMessage: "Something went wrong when registering")
        }
    }
    
    func handleLoginResponse(token: Token, username: String){
        CurrentUser.username = username
        CurrentUser.token = token.value
        self.performSegue(withIdentifier: "RegisterToWriteSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterToWriteSegue" {
            print("RegisterToWriteSegue")
            let writePostViewController = segue.destination as! WritePostViewController
            writePostViewController.postText = writePostText
            writePostViewController.sendPostNow = true
        }
        if segue.identifier == "RegisterToLoginSegue" {
            print("RegisterToLoginSegue")
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.writePostText = writePostText
        }
    }
    
    override func handle(error: NSError) {
        let statusCode = error.code
        if statusCode == 400 {
            popUpError(withTitle: "Username Taken", withMessage: "Sorry! that username is already taken")
        }
        else{
            super.handle(error: error)
        }
    }
}
