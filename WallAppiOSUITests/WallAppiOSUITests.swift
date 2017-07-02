//
//  WallAppiOSUITests.swift
//  WallAppiOSUITests
//
//  Created by Matthew Drill on 7/1/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class WallAppiOSUISpec: QuickSpec {
    override func spec(){
        super.spec()
    
        describe("Login Then Post") {
            let testText = "Post Something"
            let username = "user1"
            let password = "password"
            
            context("Success"){
                it("Does not show any alert messages and shows views in right order") {
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses", "Success"]
                    app.launch()
                    
                    let table = app.tables.element
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
                    
                    expect(table.exists).toEventually(beTrue())
                }
            }
            context("Incorrect username or password"){
                it("Shows an alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses", "400_ERRORS"]
                    app.launch()
                    
                    let table = app.tables.element
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
                    
                    let errorAlert = app.alerts["Error"]
                    
                    expect(errorAlert.)
                    
                }
            }
        }
    }
}
