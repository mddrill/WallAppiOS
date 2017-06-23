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
    var postText: String!
    
    override func viewDidLoad(){
        if sendPostNow {
            self.post()
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    @IBOutlet weak var textView: UITextView!
    let postClient = PostServiceClient.sharedInstance
    
    @IBAction func sendPost(_ sender: UIButton) {
        postText = self.textView.text
        self.post()
    }
    
    func post(){
        if BaseServiceClient.username == nil || BaseServiceClient.password == nil {
            // If the user is not logged in, make them log in
            performSegue(withIdentifier: "WriteToLoginSegue", sender: self)
        }
        else{
            // If they are logged in, post their message and go back to wall
            self.postClient.createPost(postText!) { response in
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
            loginViewController.writePostText = postText
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
