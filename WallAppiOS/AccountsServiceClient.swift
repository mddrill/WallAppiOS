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
                print("Response from register user request:")
                self.printResponse(response: response)
                completionHandler(response)
        }
    }
    
    // Gets authentication token from login endpoint
    func login(WithUsername username:String, AndPassword password:String, completionHandler:@escaping (DataResponse<Any>) -> Void) {
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
                else {
                    print("Could not login error = \(String(describing: response.result.error))")
                }
                print("Response to login request")
                self.printResponse(response: response)
                completionHandler(response)
        }
        
        
    }
    
    func logOut(){
        BaseServiceClient.token = nil
        BaseServiceClient.username = nil
    }
    
    // These three methods are for extra features which I did not have time to implement

    // Method to view Account info
    func viewAccount(id: Int, completionHandler: @escaping (DataResponse<Any>) -> Account){
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.error != nil {
//                    self.printResponse(response: response)
                    completionHandler(response)
                    return
                }
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
                if response.result.error != nil {
//                    self.printResponse(response: response)
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
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForAccounts())/\(id)", method: .patch, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if response.result.error != nil {
//                    self.printResponse(response: response)
                    completionHandler(response)
                    return
                }
        }
    }
}
