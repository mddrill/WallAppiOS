//
//  RegisterPostThenDelete.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/2/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class RegisterPostThenDeleteUITest: QuickSpec {
    
    override func spec() {
        
        describe("Register, post, then delete a post"){
            let testText = "Post Something"
            let username = "user1"
            let password = "password"
            let email = "email@email.com"
            
            context("Success"){
                it("Doesn't show an alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    app.buttons["Write Something"].tap()
                    
                    let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    textView.tap()
                    textView.typeText(testText)
                    app.buttons["Post To Wall"].tap()
                    app.buttons["Register"].tap()
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterPasswordTextField = app.textFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.textFields["Re-enter Password"]
                    enterPassword2TextField.tap()
                    enterPassword2TextField.typeText(password)
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    
                    let deleteButton = cell.buttons["Delete"]
                    expect(deleteButton.exists).to(beTrue())
                    
                    deleteButton.tap()
                    
                    expect(table.exists).toEventually(beTrue())
                }
            }
            context("Logging out before pressing delete button"){
                it("Asserts that the delete button is not there"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    app.buttons["Write Something"].tap()
                    
                    let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    textView.tap()
                    textView.typeText(testText)
                    app.buttons["Post To Wall"].tap()
                    app.buttons["Register"].tap()
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterPasswordTextField = app.textFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.textFields["Re-enter Password"]
                    enterPassword2TextField.tap()
                    enterPassword2TextField.typeText(password)
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    
                    let logoutButton = app.buttons["Log Out"]
                    logoutButton.tap()
                    
                    let deleteButton = cell.buttons["Delete"]
                    expect(deleteButton.exists).toNot(beTrue())
                }
            }
        }
        
    }
}
