//
//  PostServiceClientTest.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest

class PostServiceClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatePost() {
        // Assert error when trying to create post anonymously
        
        // Assert success when trying to create post after logging in
    }
    
    func testCreatePostTime() {
        // Test time to create post
        self.measure {
            // Create Post
        }
    }
    
    func testGetPosts() {
        // Assert success when trying to get posts anonymously
    }
    
    func testGetPostsTime() {
        // Test time to get posts
        self.measure {
            // Get posts
        }
    }
    
    func testEditPost() {
        // Assert error when trying to edit post anonymously
        
        // Assert error when user 2 tries to edit post created by user 1
        
        // Assert success when user 1 tries to edit post created by user 1
    }
    
    func testEditPostTime() {
        // Test time to edi post
        self.measure {
            // Edit Post
        }
    }
    
    func testDeletePost() {
        // Assert error when trying to delete post anonymously
        
        // Assert error when user 2 tries to delete post created by user 1
        
        // Assert success when user 1 tries to delete post created by user 1    }
    
    func testDeletePostTime() {
        // Test time to delet post
        self.measure {
            // Delete Post
        }
    }
}
}
