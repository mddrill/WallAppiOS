//
//  ServiceClient.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
import Foundation
import Alamofire

typealias RequestCallback = (DataResponse<Any>) -> Void

public class BaseServiceClient {
    /*
     * Parent class for all service clients
    */
    
    static var token: String!
    static var username: String!
    
    var sessionManager : SessionManager!
    
    init() {
        self.sessionManager =  SessionManager(configuration: URLSessionConfiguration.default)
    }

    func printResponse(response: DataResponse<Any>){
        print("Success: \(response.result.isSuccess)")
        if let value = response.result.value {
            print("Response: \(value)")
        }
        if let body = response.request!.httpBody {
            print("Request was: \(body)")
        }
        
        let statusCode = response.response?.statusCode
        if let error = response.result.error as? AFError {
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    print("Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    print("Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    print("Response status code was unacceptable: \(code)")
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            }
            
            print("Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = response.result.error as? URLError {
            print("URLError occurred: \(error)")
        } else {
            print("Unknown error: \(String(describing: response.result.error))")
        }
        
        print("Status Code: \(String(describing: statusCode))")
    }
}
