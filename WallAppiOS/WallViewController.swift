//
//  ViewController.swift
//  TextViews
//
//  Created by Matthew Drill on 6/22/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
}

class WallViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    var postsWrapper: PostWrapper!
    var isLoadingPosts = false
    
    var postToEdit: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.loadFirstPosts()
        
        // If logged in create log out button
        if CurrentUser.loggedIn() {
            let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(self.logOut))
            self.navigationItem.rightBarButtonItem = logOutButton
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as! PostTableViewCell
        
        if posts.count >= indexPath.row {
            let postToShow = posts[indexPath.row]
            cell.label.text = "\(postToShow.author!) posted this on \(postToShow.postedAt!)"
            cell.textView.text = postToShow.text
            
            // If the user is logged in and this post belongs to them, they see an edit and delete button on their posts
            if CurrentUser.loggedIn() && postToShow.belongsTo(author: CurrentUser.username){
                cell.deleteButton.tag = postToShow.id
                cell.deleteButton.addTarget(self, action: #selector(pressDeleteButton), for: .touchUpInside)
                
                cell.editButton.tag = indexPath.row
                cell.editButton.addTarget(self, action: #selector(pressEditButton), for: .touchUpInside)
            }
            // Otherwise the delete and edit buttons are hidden
            else {
                cell.deleteButton.isHidden = true
                cell.editButton.isHidden = true
            }
            
            // See if we need to load more posts
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = posts.count
            if (!self.isLoadingPosts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.postsWrapper.count ?? 0
                let remainingPostsToLoad = totalRows - rowsLoaded;
                if (remainingPostsToLoad > 0) {
                    self.loadMorePosts()
                }
            }
        }
        
        return cell
    }
    
    func loadFirstPosts() {
        print("Loading first page of posts")
        self.isLoadingPosts = true
        postClient.getPosts(onSuccess: { result in
            if result.error is BackendError {
                self.isLoadingPosts = false
                self.popUpError(withTitle: "Server Error", withMessage: "The server gave an invalid response")
            }
            else {
                self.postsWrapper = result.value
                self.posts += self.postsWrapper.posts
                self.isLoadingPosts = false
                self.tableView?.reloadData()
            }
        }, onError: { error in
            self.handleError(error: error)
        })
    }
    
    func loadMorePosts() {
        print("Loading more posts")
        self.isLoadingPosts = true
        if let wrapper = self.postsWrapper,
            posts.count < wrapper.count {
            // If this throws an error, loadMorePosts was called while postsWrapper.next is nil,
            // Something is wrong, app should crash
            try! postClient
                .getMorePosts(withWrapper: wrapper,
                              onSuccess: { result in
                                if result.error is BackendError {
                                    self.isLoadingPosts = false
                                    self.popUpError(withTitle: "Server Error", withMessage: "The server gave an invalid response")
                                }
                                else {
                                    self.postsWrapper = result.value
                                    self.posts += self.postsWrapper.posts
                                    self.isLoadingPosts = false
                                    self.tableView?.reloadData()
                                }
                }, onError: { error in
                    self.handleError(error: error)
                })
        }
    }

    func exitApp(action: UIAlertAction){
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    func logOut(){
        self.navigationItem.rightBarButtonItem = nil
        CurrentUser.logOut()
        self.reloadPosts()
    }
    
    func reloadPosts() {
        self.posts = []
        self.postsWrapper = nil
        self.loadFirstPosts()
    }
    
    func pressEditButton(sender: UIButton) {
        // postIdx is the posts index number in the posts array, not the post's id on the backend
        let postIdx = sender.tag
        postToEdit = posts[postIdx]
        performSegue(withIdentifier: "WallToEditSegue", sender: self)
        self.reloadPosts()
    }
    
    func pressDeleteButton(sender: UIButton) {
        let postId = sender.tag
        // If this throws an error, it means the user was able to delete a post without loging, in. Something is wrong, app needs to crash
        try! postClient.delete(postWithId: postId,
                                onSuccess: { _ in
                                    self.reloadPosts()},
                                onError: { error in
                                    self.handleError(error: error)
                                    })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WallToEditSegue" {
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.postText = postToEdit.text
            editPostViewController.postId = postToEdit.id
        }
    }
    
    override func handleError(error: NSError) {
        let statusCode = error.code
        if 500...599 ~= statusCode  {
            popUpError(withTitle: "Server Error", withMessage: "Could not connect to server", withAction: self.exitApp)
        }
        else{
            popUpError(withTitle: "Server Error", withMessage: "Did you remember to run the server on localhost?", withAction: self.exitApp)
        }
    }
}

