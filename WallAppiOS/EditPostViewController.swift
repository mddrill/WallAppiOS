//
//  EditPostViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class EditPostViewController: BaseViewController {

    // Used for setting the post's current text
    var postText: String!
    var postId: Int!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if postText != nil {
            textView.text = postText
            postText = nil
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func confirmEdit(_ sender: UIButton) {
        guard self.validate(textView: textView) else {
            popUpError(withTitle: "Empty Post", withMessage: "You can't send an empty post!")
            return
        }
        // If this throws an error, it means the user was able to get to this view without logging, in. 
        // Something is wrong, app needs to crash
        try! self.postClient.edit(postWithId: self.postId!,
                                  withNewText: textView.text!,
                                  onSuccess:  {_ in
                                    self.performSegue(withIdentifier: "EditToWallSegue", sender: self)},
                                  onError:  { error in
                                    self.handleError(error: error)
                                    })
    }
}
