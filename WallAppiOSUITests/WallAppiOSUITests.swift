//
//  WallAppiOSUITests.swift
//  WallAppiOSUITests
//
//  Created by Matthew Drill on 7/1/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
@testable import WallAppiOS

class WallAppiOSUITests: XCTestCase {
    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["StubNetworkResponses"]
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoginThenPost() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testText = "Post Something"
        let username = "user1"
        let password = "password"
        
        let table = app.tables.element
        XCTAssertTrue(table.exists)
        
        let originalCellCount = table.cells.count
        
        app.buttons["Write Something"].tap()
        
        let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText(testText)
        app.buttons["Post To Wall"].tap()
        
        let enterUsernameTextField = app.textFields["Enter Username"]
        enterUsernameTextField.tap()
        enterUsernameTextField.typeText(username)
        
        let enterPasswordTextField = app.textFields["Enter Password"]
        enterPasswordTextField.tap()
        enterPasswordTextField.typeText(password)
        
        app.buttons["Login"].tap()
        
        
        expectation( for: NSPredicate(format: "exists == 1"), evaluatedWith: table, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let cell = table.cells.element(boundBy: originalCellCount+1)
        XCTAssertTrue(cell.exists)
        let text = cell.staticTexts[testText]
        XCTAssert(text.exists)
    }
    
}
