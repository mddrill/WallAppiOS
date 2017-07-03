//
//  WallApp.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation
import Alamofire

typealias PostWrapperResultCallBack = (Result<PostWrapper>) -> Void

enum BackendError: Error {
    case invalidJSON
    case postListResponseDoesNotHaveResultField
    case postDoesNotHaveProperFields
}

enum PostError: Error {
    case notLoggedIn
    case wrapperDoesntHaveNextURL
}

public class PostServiceClient: BaseServiceClient {
    
    // This class connects to the post app on the backend
    
    static let sharedInstance: PostServiceClient = PostServiceClient()
    
    static func endpointForPost() -> String {
        return "https://127.0.0.1:8000/post/"
    }
    static func endpointForPost(withId id: Int) -> String {
        return "https://127.0.0.1:8000/post/\(id)/"
    }
    
    // Method to post to the wall
    func create(postWithText text: String,
                onSuccess: @escaping VoidCallBack,
                onError: @escaping ErrorCallBack) throws {
        // Make sure user is logged in
        guard let token = CurrentUser.token else {
            throw PostError.notLoggedIn
        }
        // Add parameters
        let parameters: [String: String] = [
            "text": text,
        ]
        let headers = ["Authorization": "Token \(token)"]
        self.sessionManager.request(PostServiceClient.endpointForPost(), method: .post, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    onSuccess()
                case .failure(let error):
                    onError(error as NSError)
                }
        }
    }
    
    func getMorePosts(withWrapper wrapper: PostWrapper,
                      onSuccess: @escaping PostWrapperResultCallBack,
                      onError: @escaping ErrorCallBack) throws {
        guard let nextURL = wrapper.next else {
            throw PostError.wrapperDoesntHaveNextURL
        }
        self.getPosts(path: nextURL, onSuccess: onSuccess, onError: onError)
    }
    
    func getPosts(path: String = PostServiceClient.endpointForPost(),
                  onSuccess: @escaping PostWrapperResultCallBack,
                  onError: @escaping ErrorCallBack) {
        
        // Send request to backend
        self.sessionManager.request(path)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String: Any] else {
                        // Succeeded in sending request, failed to get valid response
                        onSuccess(.failure(BackendError.invalidJSON))
                        return
                    }
                    var wrapper: PostWrapper = PostWrapper()
                    wrapper.next = json["next"] as? String
                    wrapper.previous = json["previous"] as? String
                    wrapper.count = json["count"] as? Int
                    
                    var allPosts: [Post] = []
                    guard let results = json["results"] as? [[String: Any]] else {
                        // Succeeded in sending request, failed to get valid response
                        onSuccess(.failure(BackendError.postListResponseDoesNotHaveResultField))
                        return
                    }
                    for jsonPost in results {
                        guard let post = Post(json: jsonPost) else {
                            // Succeeded in sending request, failed to get valid response
                            onSuccess(.failure(BackendError.postDoesNotHaveProperFields))
                            return
                        }
                        allPosts.append(post)
                    }
                    wrapper.posts = allPosts
                    onSuccess(.success(wrapper))
                case .failure(let error):
                    onError(error as NSError)
                }
        }
    }
    
    // Method to delete post
    func delete(postWithId id: Int,
                onSuccess: @escaping VoidCallBack,
                onError: @escaping ErrorCallBack) throws{
        // Make sure user is logged in
        guard let token = CurrentUser.token else {
            throw PostError.notLoggedIn
        }
        let headers = ["Authorization": "Token \(token)"]
        self.sessionManager.request(PostServiceClient.endpointForPost(withId: id), method: .delete, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    onSuccess()
                case .failure(let error):
                    onError(error as NSError)
                }
        }
    }
    
    // Method to edit post
    func edit(postWithId id:Int, withNewText newText: String,
              onSuccess: @escaping VoidCallBack,
              onError: @escaping ErrorCallBack) throws{
        // Make sure user is logged in
        guard let token = CurrentUser.token else {
            throw PostError.notLoggedIn
        }
        // Add parameters
        let parameters: [String: String] = [
            "text": newText,
            ]
        let headers = ["Authorization": "Token \(token)"]
        self.sessionManager.request(PostServiceClient.endpointForPost(withId: id), method: .patch, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success:
                    onSuccess()
                case .failure(let error):
                    onError(error as NSError)
                }
        }
    }
    
}
