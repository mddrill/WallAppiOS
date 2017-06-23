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
    
    let username = "testuser1"
    let password = "testpassword1"
    let email = "test@email.com"
    
    override func setUp() {
        super.setUp()
        //Register a user so that we can test writing  to the wall under that name
        accountsClient.register(User: username, WithPassword: password, AndEmail: email, completionHandler: {_ in })
        
        // Reset username and password each time so that we only log in to tests where we need to log in
        BaseServiceClient.username = nil
        BaseServiceClient.password = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test that users can read the wall posts
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
    
    // Test that users can write to the wall after login
    func testCreatePost(){
        accountsClient.login(WithUsername: username, AndPassword: password)
        postClient.createPost("Test text") { response in
            let status = response.response?.statusCode
            //            print("here:\(status)")
            XCTAssertEqual(status!, 201)
        }
    }
}
