//
//  Login.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/3/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class Login: QuickSpec {
    override func spec(){
        super.spec()
        
        describe("Login ") {
            let username = "user1"
            let password = "password"
            
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
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    app.buttons["Login"].tap()
                    
                    expect(table.exists).toEventually(beTrue())
                    expect(cell.buttons["Delete"].exists).to(beTrue())
                    expect(cell.buttons["Edit"].exists).to(beTrue())
                }
            }
            context("Incorrect username or password"){
                it("Shows an alert"){
                    let app = XCUIApplication()
                    self.continueAfterFailure = false
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launchEnvironment = ["https://127.0.0.1:8000/api-token-auth/": "400"]
                    app.launch()
                    
                    let table = app.tables.element
                    expect(table.exists).toEventually(beTrue())
                    
                    let cell = table.cells.element(boundBy: 0)
                    expect(cell.staticTexts["user1 posted this on Fri Jun 30, 2017"].exists).to(beTrue())
                    expect(cell.buttons["Delete"].exists).toNot(beTrue())
                    expect(cell.buttons["Edit"].exists).toNot(beTrue())
                    
                    let loginButton = app.buttons["Log In"]
                    loginButton.tap()
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText("not real username")
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText("not real password")
                    
                    app.buttons["Login"].tap()
                    
                    let errorAlert = app.alerts["Invalid Credentials"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                    
                }
            }
            context("Username field is empty"){
                it("Shows an alert"){
                    
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
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
                    enterPasswordTextField.tap()
                    enterPasswordTextField.typeText(password)
                    
                    app.buttons["Login"].tap()
                    
                    let errorAlert = app.alerts["Empty Fields"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
            context("Password field is empty"){
                it("Shows an alert"){
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
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    app.buttons["Login"].tap()
                    
                    let errorAlert = app.alerts["Empty Fields"]
                    
                    expect(errorAlert.exists).toEventually(beTrue())
                }
            }
        }
    }
}
