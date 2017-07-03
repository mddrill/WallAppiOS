//
//  AccountsService.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation
import Alamofire

typealias TokenUsernameCallBack = (Token, String) -> Void
typealias UsernamePasswordCallBack = (String, String) -> Void

enum RegistrationError: Error {
    case usernameAlreadyExists
    case emailIsInvalid
    case passwordsDontMatch
}

class AccountsServiceClient: BaseServiceClient {
    
    // This class connects to the accounts app in the backend
    
    static let sharedInstance: AccountsServiceClient = AccountsServiceClient()
    
    static func endpointForAccounts() -> String{
        return "https://127.0.0.1:8000/accounts/"
    }
    
    static func endpointForAccounts(withId id: Int) -> String{
        return "https://127.0.0.1:8000/accounts/\(id)"
    }
    
    static func endpointForLogin() -> String {
        return "https://127.0.0.1:8000/api-token-auth/"
    }
    
    // Method to register a new user
    func register(username: String, password1: String,
                  password2: String, email: String,
                  onSuccess: @escaping UsernamePasswordCallBack,
                  onError: @escaping ErrorCallBack) throws {
        
        guard password1 == password2 else {
            throw RegistrationError.passwordsDontMatch
        }
        guard email.isValidEmail() else {
            throw RegistrationError.emailIsInvalid
        }
        
        // Add parameters
        let parameters: [String: String] = [
            "username": username,
            "password": password1,
            "email": email
        ]
        // Send request to backend
        self.sessionManager.request(AccountsServiceClient.endpointForAccounts(), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result{
                case .success:
                    onSuccess(username, password1)
                case .failure(let error):
                    onError(error as NSError)
                }
            }
    
    }
    
    // Gets authentication token from login endpoint
    func login(username:String,
               password:String,
               onSuccess: @escaping TokenUsernameCallBack,
               onError:  @escaping ErrorCallBack) {
        print("login called")
        let parameters: [String: String] = [
            "username": username,
            "password": password,
        ]

        // Send request to backend
        self.sessionManager.request(AccountsServiceClient.endpointForLogin(), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON {response in
                switch response.result {
                case .success(let value):
                    // If case is success and response is not json, something is wrong, app should crash
                    let json = value as! [String: Any]
                    onSuccess(Token(json: json)!, username)
                case .failure(let error):
                    onError(error as NSError)
                }
        }
    }
    
    // These three methods are for extra features which I did not have time to implement

    // Method to view Account info
    func viewAccount(id: Int, completionHandler: @escaping RequestCallback){
        let token = CurrentUser.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request(AccountsServiceClient.endpointForAccounts(withId: id), method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                completionHandler(response)
        }
    }
    
    // Method to delete Account
    func deleteAccount(id: Int, completionHandler: @escaping RequestCallback){
        let token = CurrentUser.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request(AccountsServiceClient.endpointForAccounts(withId: id), method: .delete, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                CurrentUser.logOut()
                completionHandler(response)
        }
    }
    
    // Method to edit Account information
    func editAccount(id: Int, newEmail: String, completionHandler: @escaping RequestCallback){
        let parameters: [String: String] = [
            "email": newEmail,
            ]
        let token = CurrentUser.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request(AccountsServiceClient.endpointForAccounts(withId: id), method: .patch, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                completionHandler(response)
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

