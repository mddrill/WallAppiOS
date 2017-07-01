//
//  AccountsServiceClientTest.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
@testable import WallAppiOS

class AccountsServiceClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegistration() {
        // Assert Error when email is invalid
        
        // Assert Error when passwords don't match
        
        // Assert Error when Username is taken
        
        // Assert Success when everything is right
    }
    
    func testRegistrationTime() {
        // Test time it takes to register
        self.measure {
            // Register user
        }
    }
    
    func testLogin() {
        // Assert error when credentials are invalid
        
        // Assert success when credentials are valid
    }
    
    func testLoginTime() {
        // Test time it takes to login
        self.measure {
            // Log user in
        }
    }
}
