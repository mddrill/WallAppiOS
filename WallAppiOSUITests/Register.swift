//
//  Register.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/3/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class Register: QuickSpec {
    override func spec(){
        super.spec()
        
        describe("Register") {
            let username = "user1"
            let password = "password"
            let email = "email@email.com"
            
            context("Success"){
                it("Does not show any alert messages") {
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
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
                    expect(cell.buttons["Delete"].exists).to(beTrue())
                    expect(cell.buttons["Edit"].exists).to(beTrue())
                }
            }
            context("Username is empty"){
                it("Shows an Empty Field alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
                    app.buttons["Register"].tap()
                    
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
                    
                    let errorAlert = app.alerts["Empty Fields"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                    
                }
            }
            context("Password is empty"){
                it("Shows an Empty Field alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
                    app.buttons["Register"].tap()
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    let errorAlert = app.alerts["Empty Fields"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Email is empty"){
                it("Shows an Empty Field alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
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
                    
                    app.buttons["Register"].tap()
                    
                    let errorAlert = app.alerts["Empty Fields"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Passwords don't match"){
                it("Shows a  Passwords don't match alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
                    app.buttons["Register"].tap()
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterPasswordTextField = app.textFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    let enterPassword2TextField = app.textFields["Re-enter Password"]
                    enterPassword2TextField.tap()
                    enterPassword2TextField.typeText("Doesn't match first password")
                    
                    let enterEmailTextField = app.textFields["Enter Email Address"]
                    enterEmailTextField.tap()
                    enterEmailTextField.typeText(email)
                    
                    app.buttons["Register"].tap()
                    
                    let errorAlert = app.alerts["Passwords don't match"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Email address is not a valid email"){
                it("Shows an Invalid Email error"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
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
                    enterEmailTextField.typeText("Not a real email")
                    
                    app.buttons["Register"].tap()
                    
                    let errorAlert = app.alerts["Invalid Email"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Username is taken"){
                it("Shows a Username Taken alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launchEnvironment = ["https://127.0.0.1:8000/accounts/": "400"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
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
                    
                    let errorAlert = app.alerts["Username Taken"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
        }
    }
}
