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

class WallViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post]!
    var postsWrapper: PostWrapper!
    var isLoadingPosts = false
    
    var postToEdit: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.loadFirstPosts()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if let posts = self.posts {
            return posts.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postcell", for: indexPath) as! PostTableViewCell
        
        if posts != nil && posts.count >= indexPath.row {
            let postToShow = posts[indexPath.row]
            cell.label.text = "\(postToShow.author!) posted this on \(postToShow.postedAt!)"
            cell.textView.text = postToShow.text
            
            // If the user is logged in and this post belongs to them, they see an edit and delete button on their posts
            if AccountsServiceClient.loggedIn() && postToShow.belongsTo(author: BaseServiceClient.username){
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
    
    override func logOut(){
        super.logOut()
        self.reloadPosts()
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
        // If this throws an error, it means the user was able to delete a post without loging, in. Something is wrong, app needs to crash
        try! postClient.delete(postWithId: postId) { response in
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

