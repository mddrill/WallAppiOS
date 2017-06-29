//
//  WallApp.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation
import Alamofire

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

public class PostServiceClient: BaseServiceClient {
    
    // This class connects to the post app on the backend
    
    static let sharedInstance: PostServiceClient = PostServiceClient()
    
    // Method to post to the wall
    func createPost(_ text: String, completionHandler: @escaping (DataResponse<Any>) -> Void){
        // Add parameters
        let parameters: [String: String] = [
            "text": text,
        ]
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request(endpointForPost(), method: .post, parameters: parameters, headers: headers)
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

    public func getPosts(completionHandler: @escaping (Result<PostWrapper>)->Void){
        self.getPosts(AtPath: self.endpointForPost(), completionHandler: completionHandler)
    }
    
    func getMorePosts(WithWrapper wrapper: PostWrapper?, completionHandler: @escaping (Result<PostWrapper>) -> Void) {
        guard let nextURL = wrapper?.next else {
            let error = BackendError.objectSerialization(reason: "Did not get wrapper for more posts")
            completionHandler(.failure(error))
            return
        }
        self.getPosts(AtPath: nextURL, completionHandler: completionHandler)
    }
    
    func endpointForPost() -> String {
        return "https://127.0.0.1:8000/post/"
    }
    
    func postArrayFromResponse(_ response: DataResponse<Any>) -> Result<PostWrapper> {
        // Now that we've gotten a response from the backend
        guard response.result.error == nil else {
            // got an error in getting the data, need to handle it
            return .failure(response.result.error!)
        }
        
        // make sure we got JSON and turn it into a dictionary
        guard let json = response.result.value as? [String: Any] else {
            print("Didn't get post object as JSON from API")
            return .failure(BackendError.objectSerialization(reason:
                "Did not get JSON dictionary in response"))
        }
        
        // The response is in JSON format, parse it and put it in an array of Post objects
        var wrapper:PostWrapper = PostWrapper()
        wrapper.next = json["next"] as? String
        wrapper.previous = json["previous"] as? String
        wrapper.count = json["count"] as? Int
        
        var allPosts: [Post] = []
        if let results = json["results"] as? [[String: Any]] {
            for jsonPost in results {
                let post = Post(json: jsonPost)
                allPosts.append(post)
            }
        }
        wrapper.posts = allPosts
        return .success(wrapper)
    }
    
    func getPosts(AtPath path: String, completionHandler: @escaping (Result<PostWrapper>) -> Void) {
        // Make sure the url is valid
        guard var urlComponents = URLComponents(string: path) else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        urlComponents.scheme = "https"
        guard let url = try? urlComponents.asURL() else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        // Send request to backend
        self.sessionManager.request(url)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                if let error = response.result.error {
                    completionHandler(.failure(error))
//                    self.printResponse(response: response)
                    return
                }
                let postWrapperResult = self.postArrayFromResponse(response)
                completionHandler(postWrapperResult)
        }
    }

    // These methods are for extra features which I did not have time to implement
    
    // Method to delete post
    func deletePost(WithId id: Int, completionHandler: @escaping (DataResponse<Any>) -> Void){
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForPost())/\(id)", method: .delete, headers: headers)
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
    
    // Method to edit post
    func editPost(_ id:Int, post: Post, newText: String, completionHandler: @escaping (DataResponse<Any>) -> Void){
        // Add parameters
        let parameters: [String: String] = [
            "text": newText,
            ]
        let token = BaseServiceClient.token
        let headers = ["Authorization": "Token \(token!)"]
        self.sessionManager.request("\(endpointForPost())/\(id)", method: .patch, parameters: parameters, headers: headers)
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
