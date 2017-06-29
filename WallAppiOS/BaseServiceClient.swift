//
//  ServiceClient.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/19/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
import Foundation
import Alamofire

public class BaseServiceClient {
    /*
     * Parent class for all service clients
    */
    
    static var token: String!
    
    var sessionManager : SessionManager!
    
    init() {
        self.sessionManager =  SessionManager(configuration: URLSessionConfiguration.default)
    }

    func printResponse(response: DataResponse<Any>){
        print("Success: \(response.result.isSuccess)")
        print("Response: \(response.result.value)")
        print("Request was: \(response.request)")
        
        let statusCode = response.response?.statusCode
        if let error = response.result.error as? AFError {
            var privateStatusCode = error._code
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
                    privateStatusCode = code
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            }
            
            print("Underlying error: \(error.underlyingError)")
        } else if let error = response.result.error as? URLError {
            print("URLError occurred: \(error)")
        } else {
            print("Unknown error: \(response.result.error)")
        }
        
        print("Status Code: \(statusCode)")
    }
}
