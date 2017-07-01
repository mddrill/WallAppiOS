//
//  AccountsService.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation
import Alamofire

enum RegistrationError: Error {
    case usernameAlreadyExists
    case emailIsInvalid
    case passwordsDontMatch
}

class AccountsServiceClient: BaseServiceClient {
    
    // This class connects to the accounts app in the backend
    
    static let sharedInstance: AccountsServiceClient = AccountsServiceClient()
    
    static func loggedIn() -> Bool {
        return BaseServiceClient.token != nil
    }
    
    func endpointForAccounts() -> String{
        return "https://127.0.0.1:8000/accounts/"
    }
    
    func endpointForLogin() -> String {
        return "https://127.0.0.1:8000/api-token-auth/"
    }
    
    // Method to register a new user
    func register(username: String, password1: String, password2: String, email: String, completionHandler: @escaping RequestErrorCallback) throws {
        print("register called")
        
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
        self.sessionManager.request(self.endpointForAccounts(), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON {response in
                if let json = response.result.value as? [String: Any] {
                    BaseServiceClient.token = json["token"] as! String
                    BaseServiceClient.username = username
                }
                completionHandler(response)
            }
        
    }
    
    // Gets authentication token from login endpoint
    func login(username:String, password:String, completionHandler:@escaping RequestErrorCallback) {
        print("login called")
        let parameters: [String: String] = [
            "username": username,
            "password": password,
        ]
        
        // Send request to backend
        self.sessionManager.request(self.endpointForLogin(), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON {response in
                // make sure we got JSON and turn it into a dictionary
                if let json = response.result.value as? [String: Any] {
                    BaseServiceClient.token = json["token"] as! String
                    BaseServiceClient.username = username
                }
                completionHandler(response)
        }
        
        
    }
    
    func logOut(){
        BaseServiceClient.token = nil
        BaseServiceClient.username = nil
    }
    
    // These three methods are for extra features which I did not have time to implement

    // Method to view Account info
    func viewAccount(id: Int, completionHandler: @escaping (DataResponse<Any>) -> Account?){
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                completionHandler(response)
        }
    }
    
    // Method to delete Account
    func deleteAccount(id: Int, completionHandler: @escaping (DataResponse<Any>) -> Void){
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .delete, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                self.logOut()
                completionHandler(response)
        }
    }
    
    // Method to edit Account information
    func editAccount(id: Int, newEmail: String, completionHandler: @escaping (DataResponse<Any>) -> Void){
        let parameters: [String: String] = [
            "email": newEmail,
            ]
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .patch, parameters: parameters, headers: headers)
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

