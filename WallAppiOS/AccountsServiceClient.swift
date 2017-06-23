//
//  AccountsService.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation
import Alamofire

class AccountsServiceClient: BaseServiceClient {
    
    // This class connects to the accounts app in the backend
    
    static let sharedInstance: AccountsServiceClient = AccountsServiceClient()
    
    func endpointForAccounts() -> String{
        return "https://127.0.0.1:8000/accounts/"
    }
    
    // Method to register a new user
    func register(User username: String, WithPassword password: String, AndEmail email: String, completionHandler:@escaping (DataResponse<Any>) -> Void) {
        print("register called")
        
        // Add parameters
        let parameters: [String: String] = [
            "username": username,
            "password": password,
            "email": email
        ]
        // Send request to backend
        self.sessionManager.request(self.endpointForAccounts(), method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON {response in
                self.printResponse(response: response)
                completionHandler(response)
        }
    }
    
    func endpointForLogin() -> String{
        return "https://127.0.0.1:8000/api-auth/login/?next=/accounts/login/"
    }
    
    // Stores the username and password in global variables for authentication while the app is open
    func login(WithUsername username:String, AndPassword password:String){
        BaseServiceClient.username = username
        BaseServiceClient.password = password
    }
    
    // These three methods are for extra features which I did not have time to implement

    // Method to view Account info
    func viewAccount(id: Int, completionHandler: @escaping (DataResponse<Any>) -> Account){
        let user = BaseServiceClient.username
        let password = BaseServiceClient.password
        let credentialData = "\(user!):\(password!)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.error != nil {
                    self.printResponse(response: response)
                    completionHandler(response)
                    return
                }
        }
    }
    
    // Method to delete Account
    func deleteAccount(id: Int, completionHandler: @escaping (DataResponse<Any>) -> Void){
        let user = BaseServiceClient.username
        let password = BaseServiceClient.password
        let credentialData = "\(user!):\(password!)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .delete, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.error != nil {
                    self.printResponse(response: response)
                    completionHandler(response)
                    return
                }
        }
    }
    
    // Method to edit Account information
    func editAccount(id: Int, newEmail: String, completionHandler: @escaping (DataResponse<Any>) -> Void){
        let parameters: [String: String] = [
            "email": newEmail,
            ]
        let user = BaseServiceClient.username
        let password = BaseServiceClient.password
        let credentialData = "\(user!):\(password!)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .patch, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.error != nil {
                    self.printResponse(response: response)
                    completionHandler(response)
                    return
                }
        }
    }
}
