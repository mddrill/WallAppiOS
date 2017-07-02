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

class AccountsServiceClientSpec: QuickSpec {
    let accountsClient = AccountsServiceClient.sharedInstance
    
    override func spec() {
        super.spec()
        
        describe("Register User") {
            let username = "user1"
            let password = "password"
            let email = "email@email.com"
            
            context("Success"){
                it("Doesn't return error") {
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "RegisterUser", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(AccountsServiceClient.endpointForAccounts()), jsonData(data as Data, status: 201))
                    
                    expect { try self.accountsClient.register(username: username, password1: password,
                                                 password2: password, email: email) { response in
                        requestError = response.result.error
                        }}.toNot(throwError())
                    expect(requestError).toEventually(beNil())
                }
            }
            context("Invalid Email") {
                it("Throws an emailIsInvalid error"){
                    expect { try self.accountsClient.register(username: username, password1: password,
                                                              password2: password, email: "not valid") {_ in}}.to(throwError(RegistrationError.emailIsInvalid))
                }
            }
            context("Passwords don't match") {
                it("Throws a passwordsDontMatch error") {
                    expect { try self.accountsClient.register(username: username, password1: password,
                                                              password2: "not same password", email: email) {_ in}}.to(throwError(RegistrationError.passwordsDontMatch))
                }
            }
            context("Username is taken") {
                it("Returns an error") {
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 400, userInfo: nil)
                    self.stub(uri(AccountsServiceClient.endpointForAccounts()), failure(error))
                    
                    expect { try self.accountsClient.register(username: username, password1: password,
                                                              password2: password, email: email) { response in
                                                                requestError = response.result.error
                        }}.toNot(throwError())
                    expect(requestError).toEventuallyNot(beNil())

                }
            }
            context("Server error"){
                it("Returns an error"){
                    var requestError: Error!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(AccountsServiceClient.endpointForAccounts()), failure(error))
                    
                    expect { try self.accountsClient.register(username: username, password1: password,
                                                              password2: password, email: email) { response in
                                                                requestError = response.result.error
                        }}.toNot(throwError())
                    expect(requestError).toEventuallyNot(beNil())
                }
            }
        }
        describe("Login"){
            let username = "user1"
            let password = "password"
            context("Success") {
                it("Returns token") {
                    let path = Bundle(for: type(of: self)).path(forResource: "Login", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(AccountsServiceClient.endpointForLogin()), jsonData(data as Data, status: 200))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    var userToken: String!
                    var user: String!
                    self.accountsClient.login(username: username, password: password,
                                              onSuccess: { token, username in
                                                wasSuccess = true
                                                userToken = token.value
                                                user = username
                                                },
                                              onError: { _ in
                                                    wasFailure = true
                                                })
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(userToken).toEventually(equal("6f6a7ff11a8c2ff44423a3982ff81623cc35ed87"))
                    expect(user).toEventually(equal(username))
                }
                
            }
            context("Credentials incorrect") {
                it("Does not throw frontend error but returns a backend one") {
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 400, userInfo: nil)
                    self.stub(uri(AccountsServiceClient.endpointForLogin()), failure(error))
                    
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.accountsClient.login(username: username, password: "Not the right password",
                                              onSuccess: {_ in
                                                wasSuccess = true
                                                },
                                              onError: { error in
                                                wasFailure = true
                                                requestError = error
                                                })
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(400))
                }
            }
            context("Getting a server error") {
                it("Does not throw frontend error but returns a backend one") {
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(AccountsServiceClient.endpointForLogin()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.accountsClient.login(username: username, password: "Not the right password",
                                              onSuccess: {_ in
                                                wasSuccess = true
                    },
                                              onError: { error in
                                                wasFailure = true
                                                requestError = error
                    })
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    expect(requestError.code).toEventually(equal(500))
                }
            }
        }
    }
}
