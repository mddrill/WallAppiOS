//
//  EditPostViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class EditPostViewController: UIViewController {

    // Used for setting the post's current text
    var postText: String!
    var postId: Int!
    
    override func viewDidLoad(){
        if postText != nil {
            textView.text = postText
            postText = nil
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WritePostViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBOutlet weak var textView: UITextView!
    let postClient = PostServiceClient.sharedInstance
    
    @IBAction func confirmEdit(_ sender: UIButton) {
        self.editPost()
        performSegue(withIdentifier: "EditToWallSegue", sender: self)
    }
    
    func editPost(){
        guard self.validate(textView: textView) else {
            let alert = UIAlertController(title: "Couldn't post", message: "You can't send an empty post!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.postClient.edit(postWithId: self.postId!, withNewText: textView.text!) { response in
                if let error = response.result.error {
                    let alert = UIAlertController(title: "Error", message: "Could not edit post: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
