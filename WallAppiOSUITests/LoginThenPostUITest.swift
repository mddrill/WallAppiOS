import XCTest
import Quick
import Nimble
@testable import WallAppiOS

class LoginThenPostUITest: QuickSpec {
    override func spec(){
        super.spec()
        
        describe("Login Then Post") {
            let testText = "Post Something"
            let username = "user1"
            let password = "password"
            
            context("Success"){
                it("Does not show any alert messages") {
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
                    
                    let enterUsernameTextField = app.textFields["Enter Username"]
                    enterUsernameTextField.tap()
                    enterUsernameTextField.typeText(username)
                    
                    let enterPasswordTextField = app.secureTextFields["Enter Password"]
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
                    app.launchArguments = ["StubNetworkResponses"]
                    app.launchEnvironment = ["https://127.0.0.1:8000/api-token-auth/": "400"]
                    app.launch()
                    
                    app.buttons["Write Something"].tap()
                    
                    let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    textView.tap()
                    textView.typeText(testText)
                    app.buttons["Post To Wall"].tap()
                    
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
                    
                    app.buttons["Write Something"].tap()
                    
                    let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    textView.tap()
                    textView.typeText(testText)
                    app.buttons["Post To Wall"].tap()
                    
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
                    
                    app.buttons["Write Something"].tap()
                    
                    let textView = app.otherElements.containing(.navigationBar, identifier:"Write Something").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
                    
                    textView.tap()
                    textView.typeText(testText)
                    app.buttons["Post To Wall"].tap()
                    
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
