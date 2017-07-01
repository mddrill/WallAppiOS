//
//  WallAppiOSTests.swift
//  WallAppiOSTests
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Alamofire
@testable import WallAppiOS

class WallAppiOSTests: XCTestCase {
    
    let postClient = PostServiceClient.sharedInstance
    let accountsClient = AccountsServiceClient.sharedInstance
    
    let username = "testuser235yui34"
    let password = "testpasswordhbihjin34"
    let email = "test@email.com"
    
    let username2 = "test2user235yui34"
    let password2 = "test2passwordhbihjin34"
    let email2 = "test2@email.com"
    
    let testText = "Test text"
    let newText = "New text"
    
    override func setUp() {
        super.setUp()
        //Register a user so that we can test writing  to the wall under that name
        accountsClient.register(username: username, password: password, email: email, completionHandler: {_ in })
        accountsClient.register(username: username2, password: password2, email: email2, completionHandler: {_ in })
        
        // Reset token each time so that we only log in to tests where we need to log in
        BaseServiceClient.token = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test that users can read the wall posts without logging in
    func testGetPost(){
        var postsWrapper: WallAppiOS.PostWrapper?
        postClient.getPosts{ result in
            postsWrapper = result.value
            XCTAssertNotNil(postsWrapper, "Post wrapper is nil after postClient.getPosts")
            XCTAssertNotNil(postsWrapper?.posts, "Posts array is nil after postClient.getPosts")
            XCTAssertEqual(postsWrapper?.count, 10, "Post wrapper is not equal to 10 after postClient.getPosts")
            XCTAssertEqual(postsWrapper?.posts.count, 10, "Posts array length is not equal to 10 after postClient.getPosts")
        }
    }
    
    // Test that users can write to the wall after login but not before
    func testCreatePost(){
        //Posting anonymously should thow an error when trying to unwrap a nil token
//        XCTAssertThrowsError(try {_ in
//            self.postClient.create(postWithText: testText) {_ in}
//        })
        
        accountsClient.login(username: username, password: password){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 1")
            self.postClient.create(postWithText: self.testText) { response in
                let status = response.response?.statusCode
                // print("here:\(status)")
                XCTAssertEqual(status!, 201, "Was not able to create a post after logging in")
            }
        }
    }
    
    // Test that users can edit their own posts but not others and not without logging in
    func testEditPost(){
        
        // Post something as user 1
        var postId: Int!
        accountsClient.login(username: username, password: password){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 1")
            self.postClient.create(postWithText: self.testText) { response in
                let json = response.result.value as! [String: Any]
                postId = json["id"] as! Int
            }
        }
        
        self.postClient.edit(postWithId: postId!, withNewText: newText) { response in
            let status = response.response?.statusCode
            // print("here:\(status)")
            XCTAssertNotEqual(status!, 200, "Was able to edit a post anonymously")
        }
        
        // Should not be able to edit user 1's post as user2
        accountsClient.login(username: username2, password: password2){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 2")
            self.postClient.edit(postWithId: postId!, withNewText: self.newText) { response in
                let status = response.response?.statusCode
                // print("here:\(status)")
                XCTAssertNotEqual(status!, 200, "Was able to edit user 1's post as user 2")
            }
        }
        accountsClient.logOut()
        
        // Should be able to edit user 1's post as user 1
        accountsClient.login(username: username, password: password){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 1")
            self.postClient.edit(postWithId: postId!, withNewText: self.newText) { response in
                let status = response.response?.statusCode
                // print("here:\(status)")
                XCTAssertEqual(status!, 200, "Was able to edit user 1's post as user 2")
            }
        }
    }
    
    // Test that users can delete their own post, but not others
    func testDeletePost(){
        
        // Post something as user 1
        var postId: Int!
        accountsClient.login(username: username, password: password){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 1")
            self.postClient.create(postWithText: self.testText) { response in
                let json = response.result.value as! [String: Any]
                postId = json["id"] as! Int
            }
        }
        
        self.postClient.delete(postWithId: postId) { response in
            let status = response.response?.statusCode
            // print("here:\(status)")
            XCTAssertNotEqual(status!, 204, "Was able to delete a post anonymously")
        }
        
        // Should not be able to edit user 1's post as user2
        accountsClient.login(username: username2, password: password2){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 2")
            self.postClient.delete(postWithId: postId!) { response in
                let status = response.response?.statusCode
                // print("here:\(status)")
                XCTAssertNotEqual(status!, 204, "Was able to delete user 1's post as user 2")
            }
        }
        accountsClient.logOut()
        
        // Should be able to edit user 1's post as user 1
        accountsClient.login(username: username, password: password){ response in
            let status = response.response?.statusCode
            XCTAssertEqual(status!, 200, "Was not able to login as user 1")
            self.postClient.delete(postWithId: postId!) { response in
                let status = response.response?.statusCode
                // print("here:\(status)")
                XCTAssertEqual(status!, 204, "Was able to delete user 1's post as user 2")
            }
        }
    }
}
