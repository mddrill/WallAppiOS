//
//  RegisterPostThenEdit.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/2/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class RegisterPostThenEditUITest: QuickSpec {
    
    override func spec(){
        
        describe("Register, post, then edit a post"){
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
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.secureTextFields["Re-enter Password"]
                    enterPassword2TextField.tap()
                    enterPassword2TextField.typeText(password)
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    
                    let editButton = cell.buttons["Edit"]
                    expect(editButton.exists).to(beTrue())
                    
                    editButton.tap()
                    
                    let editTextView = app.otherElements.containing(.navigationBar, identifier:"Edit").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    editTextView.tap()
                    editTextView.typeText("new text")
                    
                    app.buttons["Confirm Edits"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                }
            }
            context("text field is empty"){
                it("Shows an Empty Post alert"){
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
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.secureTextFields["Re-enter Password"]
                    enterPassword2TextField.tap()
                    enterPassword2TextField.typeText(password)
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    
                    let editButton = cell.buttons["Edit"]
                    expect(editButton.exists).to(beTrue())
                    
                    editButton.tap()
                    
                    let editTextView = app.otherElements.containing(.navigationBar, identifier:"Edit").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    editTextView.doubleTap()
                    
                    app.menuItems["Select All"].tap()
                    app.keys["delete"].tap()
                    
                    app.buttons["Confirm Edits"].tap()
                    
                    let errorAlert = app.alerts["Empty Post"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Log out before pressing edit button"){
                it("Asserts that the edit button is not there"){
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
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.secureTextFields["Re-enter Password"]
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
                    
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    expect(logoutButton.exists).toNot(beTrue())
                }
            }
        }
    }
}
