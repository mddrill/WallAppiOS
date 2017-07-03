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
                it("Returns All The Posts, runs success block, not failure block"){
                    CurrentUser.token = nil
                    var postsWrapper: PostWrapper!
                    var backendError: Error!
                    var requestError: NSError!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "GetPosts", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PostServiceClient.endpointForPost()), jsonData(data as Data))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.postClient
                        .getPosts( onSuccess: { result in
                                    postsWrapper = result.value
                                    backendError = result.error
                                    wasSuccess = true
                                    },
                                   onError: { error in
                                    requestError = error
                                    wasFailure = true
                                })
                    expect(requestError).toEventually(beNil())
                    expect(backendError).toEventually(beNil())
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
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.postClient
                        .getPosts( onSuccess: { result in
                                    wasSuccess = true
                                    },
                                   onError: { error in
                                    requestError = error
                                    wasFailure = true
                                })
                    expect(requestError).toEventuallyNot(beNil())
                    expect(postsWrapper).toEventually(beNil())
                }
            }
        }
        describe("Create Post"){
            let testText = "Test Text"
            context("Without Logging In") {
                it("Throws a frontend error") {
                    CurrentUser.token = nil
                    expect{ try self.postClient.create(postWithText: testText,
                                                       onSuccess: {_ in},
                                                       onError: {_ in})
                        }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("After Logging In") {
                it("Does not throw or return an error, run success block, not failure block") {
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                
                    let path = Bundle(for: type(of: self)).path(forResource: "CreatePost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PostServiceClient.endpointForPost()), jsonData(data as Data, status: 201))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect{ try self.postClient
                                    .create(postWithText: testText,
                                           onSuccess: {_ in
                                            wasSuccess = true
                                            },
                                           onError:{ error in
                                            wasFailure = true
                                            requestError = error
                                        })
                        }.toNot(throwError())
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(requestError).toEventually(beNil())
                }
            }
            context("Getting a server error") {
                it("Does not throw frontend errror but returns a backend one, runs failure block, not success block") {
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect{ try self.postClient
                                    .create(postWithText: testText,
                                            onSuccess: {_ in
                                                wasSuccess = true
                                    },
                                            onError:{ error in
                                                wasFailure = true
                                                requestError = error
                                    })
                                    }.toNot(throwError())
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(500))
                }
            }
        }
        describe("Edit Post") {
            let testText = "Test Text"
            let postId = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    CurrentUser.token = nil
                    
                    expect { try self.postClient.edit(postWithId: postId,
                                                      withNewText: testText,
                                                      onSuccess: {_ in},
                                                      onError: {_ in}
                        ) }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Runs success block, not failure block"){
                    CurrentUser.token = "dummytoken"
                    let path = Bundle(for: type(of: self)).path(forResource: "EditPost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), jsonData(data as Data))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.edit(postWithId: postId,
                                                      withNewText: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                                                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                }
                
            }
            context("Logged In as wrong user"){
                it("Returns a backend error, failure block runs"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.edit(postWithId: postId,
                                                      withNewText: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                                                        },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                                                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(401))
                }
            }
            context("Server error") {
                it("Returns a backend error, failure block runs"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.edit(postWithId: postId,
                                                      withNewText: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                                                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                                                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(500))
                }
            }
        }
        describe("Delete Post") {
            let postId = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    CurrentUser.token = nil

                    expect { try self.postClient.delete(postWithId: postId,
                                                      onSuccess: {_ in},
                                                      onError: {_ in}
                        )
                        }.to(throwError(PostError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Does not throw or return an error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "DeletePost", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), jsonData(data as Data, status: 204))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.delete(postWithId: postId,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                                                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(requestError).toEventually(beNil())
                    
                }
                
            }
            context("Logged In as wrong user"){
                it("Returns a backend error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.delete(postWithId: postId,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(401))
                }
            }
            context("Server error") {
                it("Returns a backend error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!

                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PostServiceClient.endpointForPost(withId: postId)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.postClient.delete(postWithId: postId,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                                                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                                                    })
                        }.toNot(throwError(PostError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(500))
                }
            }
        }
    }
}
