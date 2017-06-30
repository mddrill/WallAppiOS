//
//  WritePostViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class WritePostViewController: UIViewController {
    
    // Controller for view to write a post
    
    var sendPostNow = false
    // This is so that login and register views can pass text to this view
    // When user is forced to login, the textView text is passed to the login and/or register views, then after registering
    // It is passed back to the write post view to be posted
    // Since prepareForSegue is called before the views are loaded, the text cannot be passed directly into the textView
    var postText: String!
    
    override func viewDidLoad(){
        if postText != nil {
            textView.text = postText
            postText = nil
        }
        if sendPostNow {
            self.post()
            sendPostNow = false
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WritePostViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // If logged in create log out button
        if AccountsServiceClient.loggedIn() {
            let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(self.logOut))
            self.navigationItem.rightBarButtonItem = logOutButton
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    let postClient = PostServiceClient.sharedInstance
    let accountsClient = AccountsServiceClient.sharedInstance
    
    @IBAction func sendPost(_ sender: UIButton) {
        self.post()
    }
    
    func post(){
        guard self.validate(textView: textView) else {
            let alert = UIAlertController(title: "Couldn't post", message: "You have to enter text first before you can post!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if BaseServiceClient.token == nil {
            // If the user is not logged in, make them log in
            performSegue(withIdentifier: "WriteToLoginSegue", sender: self)
        }
        else{
            // If they are logged in, post their message and go back to wall
            self.postClient.create(postWithText: textView.text!) { response in
                if let error = response.result.error {
                    let alert = UIAlertController(title: "Error", message: "Could not post: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            performSegue(withIdentifier: "WriteToWallSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WriteToLoginSegue" {
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.writePostText = textView.text
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func logOut(){
        accountsClient.logOut()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
    }
}
