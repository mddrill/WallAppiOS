//
//  WritePostViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class WritePostViewController: BaseViewController {
    
    // Controller for view to write a post
    
    var sendPostNow = false
    // This is so that login and register views can pass text to this view
    // When user is forced to login, the textView text is passed to the login and/or register views, then after registering
    // It is passed back to the write post view to be posted
    // Since prepareForSegue is called before the views are loaded, the text cannot be passed directly into the textView
    var postText: String!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad(){
        textView.text = postText
        postText = nil
        
        if sendPostNow {
            self.sendPost(postButton)
            sendPostNow = false
        }
    }
    
    @IBAction func sendPost(_ sender: UIButton) {
        guard self.validate(textView: textView) else {
            popUpError(withMessage: "You have to enter text first before you can post!")
            return
        }
        if BaseServiceClient.token == nil {
            // If the user is not logged in, make them log in
            performSegue(withIdentifier: "WriteToLoginSegue", sender: self)
        }
        else{
            // If they are logged in, post their message and go back to wall
            do{
                try self.postClient.create(postWithText: textView.text!) { response in
                    if let error = response.result.error {
                        self.handle(requestError: error)
                    }
                }
            }
            catch PostError.notLoggedIn {
                popUpError(withMessage: "You can't post without logging in first!")
            }
            catch {
                popUpError(withMessage: "Something went wrong when sending the post")
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
}
