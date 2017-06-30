//
//  ViewController.swift
//  TextViews
//
//  Created by Matthew Drill on 6/22/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
}

class WallViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Controller for view which views all posts
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post]!
    var postsWrapper: PostWrapper!
    var isLoadingPosts = false
    
    var postToEdit: Post!
    
    let postClient = PostServiceClient.sharedInstance
    let accountsClient = AccountsServiceClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //IMPORTANT: This code allows me to test this app on my local machine by turning off certificate
        //checking, I understand that it is not secure and would not put this code in production
        postClient.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: trust)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = self.postClient.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // If logged in create log out button
        if AccountsServiceClient.loggedIn() {
            let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(self.logOut))
            self.navigationItem.rightBarButtonItem = logOutButton
        }
        
        self.loadFirstPosts()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if self.posts == nil {
            return 0
        }
        return self.posts!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath) as! PostTableViewCell
        if let posts = posts, posts.count >= indexPath.row {
            let postToShow = posts[indexPath.row]
            cell.label.text = "\(postToShow.author!) posted this on \(postToShow.postedAt!)"
            cell.textView.text = postToShow.text
            
             // If the user is logged in and this post belongs to them, they see an edit and delete button on their posts
            if AccountsServiceClient.loggedIn() && postToShow.belongsTo(author: BaseServiceClient.username){
                cell.deleteButton.tag = postToShow.id
                cell.deleteButton.addTarget(self, action: #selector(pressDeleteButton), for: .touchUpInside)
                
                cell.editButton.tag = indexPath.row
                cell.editButton.addTarget(self, action: #selector(pressEditButton), for: .touchUpInside)
            } else {
            // Otherwise the delete and edit buttons are hidden
                cell.deleteButton.isHidden = true
                cell.editButton.isHidden = true
            }
            
            // See if we need to load more posts
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = posts.count
            if (!self.isLoadingPosts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = self.postsWrapper?.count ?? 0
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
        postClient.getPosts{ result in
            if let error = result.error {
                self.isLoadingPosts = false
                let alert = UIAlertController(title: "Error", message: "Could not load first posts \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: self.exitApp))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let postsWrapper = result.value
            if postsWrapper == nil || postsWrapper?.posts == nil {
                let alert = UIAlertController(title: "Error", message: "Could not load posts, server may be down", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.addPosts(FromWrapper: postsWrapper)
            self.isLoadingPosts = false
            self.tableView?.reloadData()
        }
    }
    
    func loadMorePosts() {
        print("Loading more posts")
        self.isLoadingPosts = true
        if let posts = self.posts,
            let wrapper = self.postsWrapper,
            let totalPostsCount = wrapper.count,
            posts.count < totalPostsCount {
            postClient.getMorePosts(WithWrapper: wrapper) { result in
                if let error = result.error {
                    self.isLoadingPosts = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more posts \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: self.exitApp))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                let moreWrapper = result.value
                if moreWrapper == nil || moreWrapper?.posts == nil {
                    let alert = UIAlertController(title: "Error", message: "Could not load posts, server may be down", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.addPosts(FromWrapper: moreWrapper)
                self.isLoadingPosts = false
                self.tableView?.reloadData()
            }
        }
    }
    
    func addPosts(FromWrapper wrapper: PostWrapper?) {
        print("Adding posts from wrapper to instance variable posts")
        self.postsWrapper = wrapper
        if self.posts == nil {
            self.posts = self.postsWrapper.posts
        } else {
            self.posts = self.posts + self.postsWrapper.posts
        }
    }
    
    func exitApp(action: UIAlertAction){
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    func logOut(){
        accountsClient.logOut()
        self.reloadPosts()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func reloadPosts() {
        self.posts = nil
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
        postClient.delete(postWithId: postId) { response in
            if let error = response.result.error {
                let alert = UIAlertController(title: "Error", message: "Could not delte this post: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.reloadPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WallToEditSegue" {
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.postText = postToEdit.text
            editPostViewController.postId = postToEdit.id
        }
    }
}

