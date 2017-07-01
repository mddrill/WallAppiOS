//
//  PostServiceClientTest.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Mockingjay
import Quick
import Nimble
@testable import WallAppiOS

class PostServiceClientSpec: QuickSpec {
    let postClient = PostServiceClient.sharedInstance
    
    override func spec() {
        super.spec()
        
        describe("GetPosts") {
            context("Success"){
                it("Returns All The Posts"){
                    BaseServiceClient.token = nil
                    var postsWrapper: PostWrapper!
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "GetPosts", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(self.postClient.endpointForPost()), jsonData(data as Data))
                    
                    self.postClient.getPosts{ result in
                        postsWrapper = result.value
                        requestError = result.error
                    }
                    expect(requestError).toEventually(beNil())
                    expect(postsWrapper).toEventuallyNot(beNil())
                    expect(postsWrapper.posts).toEventuallyNot(beNil())
                    expect(postsWrapper.count).to(equal(5))
                    expect(postsWrapper.posts.count).to(equal(5))
                    
                    expect(postsWrapper.posts[0].author).to(equal("user1"))
                    expect(postsWrapper.posts[0].id).to(equal(1))
                    expect(postsWrapper.posts[0].postedAt).to(equal("Fri Jun 30, 2017"))
                    expect(postsWrapper.posts[0].text).to(equal("The first post"))
                    
                    expect(postsWrapper.posts[1].author).to(equal("user2"))
                    expect(postsWrapper.posts[1].id).to(equal(3))
                    expect(postsWrapper.posts[1].postedAt).to(equal("Fri Jun 30, 2017"))
                    expect(postsWrapper.posts[1].text).to(equal("The second post"))
                    
                    expect(postsWrapper.posts[2].author).to(equal("user3"))
                    expect(postsWrapper.posts[2].id).to(equal(17))
                    expect(postsWrapper.posts[2].postedAt).to(equal("Wed May 15, 1996"))
                    expect(postsWrapper.posts[2].text).to(equal("The third post"))
                    
                    expect(postsWrapper.posts[3].author).to(equal("user4"))
                    expect(postsWrapper.posts[3].id).to(equal(42))
                    expect(postsWrapper.posts[3].postedAt).to(equal("Sat Feb 13, 2010"))
                    expect(postsWrapper.posts[3].text).to(equal("The fourth post"))
                    
                    expect(postsWrapper.posts[4].author).to(equal("user5"))
                    expect(postsWrapper.posts[4].id).to(equal(3190))
                    expect(postsWrapper.posts[4].postedAt).to(equal("Sat Oct 27, 2001"))
                    expect(postsWrapper.posts[4].text).to(equal("The fifth post"))
                    
                }
            }
            context("Error"){
                it("Returns an error"){
                    var postsWrapper: PostWrapper!
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost()), failure(error))
                    
                     self.postClient.getPosts{ result in
                        postsWrapper = result.value
                        requestError = result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                    expect(postsWrapper).toEventually(beNil())
                }
            }
        }
        describe("Create Post"){
            let testText = "Test Text"
            context("Without Logging In") {
                it("Throws a frontend error") {
                    BaseServiceClient.token = nil
                    expect{ try self.postClient.create(postWithText: testText, completionHandler: {_ in}) }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("After Logging In") {
                it("Does not throw or return an error") {
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                
                    let path = Bundle(for: type(of: self)).path(forResource: "CreatePost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(self.postClient.endpointForPost()), jsonData(data as Data, status: 201))
                    
                    expect{ try self.postClient.create(postWithText: testText, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.create(postWithText: testText) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventually(beNil())
                }
            }
            context("Getting a server error") {
                it("Does not throw frontend errror but returns a backend one") {
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost()), failure(error))
                    
                    expect{ try self.postClient.create(postWithText: testText, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.create(postWithText: testText) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                }
            }
        }
        describe("Edit Post") {
            let testText = "Test Text"
            let postId = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    BaseServiceClient.token = nil
                    
                    expect { try self.postClient.edit(postWithId: postId, withNewText: testText, completionHandler: {_ in}) }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Does not throw or return an error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "EditPost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), jsonData(data as Data))
                    
                    expect { try self.postClient.edit(postWithId: postId, withNewText: testText, completionHandler: {_ in}) }.toNot(throwError(PostError.notLoggedIn))
                    
                    try! self.postClient.edit(postWithId: postId, withNewText: testText) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventually(beNil())

                }
                
            }
            context("Logged In as wrong user"){
                it("Returns a backend error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), failure(error))
                    
                    expect{ try self.postClient.edit(postWithId: postId, withNewText: testText, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.edit(postWithId: postId, withNewText: testText) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                    
                    
                }
            }
            context("Server error") {
                it("Returns a backend error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), failure(error))
                    
                    expect{ try self.postClient.edit(postWithId: postId, withNewText: testText, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.edit(postWithId: postId, withNewText: testText) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                }
            }
        }
        describe("Delete Post") {
            let postId = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    BaseServiceClient.token = nil
                    
                    expect { try self.postClient.delete(postWithId: postId, completionHandler: {_ in}) }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Does not throw or return an error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "DeletePost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), jsonData(data as Data, status: 200))
                    
                    expect { try self.postClient.delete(postWithId: postId, completionHandler: {_ in}) }.toNot(throwError(PostError.notLoggedIn))
                    
                    try! self.postClient.delete(postWithId: postId) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventually(beNil())
                    
                }
                
            }
            context("Logged In as wrong user"){
                it("Returns a backend error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), failure(error))
                    
                    expect{ try self.postClient.delete(postWithId: postId, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.delete(postWithId: postId) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                    
                    
                }
            }
            context("Server error") {
                it("Returns a backend error"){
                    BaseServiceClient.token = "dummytoken"
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(self.postClient.endpointForPost(withId: postId)), failure(error))
                    
                    expect{ try self.postClient.delete(postWithId: postId, completionHandler: {_ in}) }.toNot(throwError())
                    
                    try! self.postClient.delete(postWithId: postId) { response in
                        requestError = response.result.error
                    }
                    expect(requestError).toEventuallyNot(beNil())
                }
            }
        }    }
}
