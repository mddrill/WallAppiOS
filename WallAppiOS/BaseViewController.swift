//
//  BaseViewController.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/30/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Alamofire

class BaseViewController: UIViewController {
    
    let accountsClient = AccountsServiceClient.sharedInstance
    let postClient = PostServiceClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // IMPORTANT: This code allows me to test this app on my local machine by turning off certificate
        // checking, I understand that it is not secure and would not put this code in production
        postClient.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: trust)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = self.postClient.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        accountsClient.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: trust)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = self.accountsClient.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        
        // If logged in create log out button
        if CurrentUser.loggedIn() {
            let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(self.logOut))
            self.navigationItem.rightBarButtonItem = logOutButton
        }
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func handle(error: NSError) {
        popUpError(withTitle: "\(error.code) Error", withMessage: "An Error Occured")
    }
    
    /*func handle(error: NSError) {
        print("Hander request error called")
        if let error = error as? AFError {
            switch error {
            case .invalidURL(let url):
                popUpError(withTitle: "\(String(describing: error.responseCode)) Error", withMessage: "This URL: \(url) is invalid")
            case .parameterEncodingFailed(let reason):
                popUpError(withTitle: "\(String(describing: error.responseCode)) Error", withMessage: "The parameters could not be encoded because: \(reason)")
            case .multipartEncodingFailed(let reason):
                popUpError(withTitle: "\(String(describing: error.responseCode)) Error",
                    withMessage: "Multipart encoding failed because: \(reason)")
            case .responseValidationFailed(let reason):
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    popUpError(withTitle: "\(String(describing: error.responseCode))", withMessage: "Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    popUpError(withTitle: "\(String(describing: error.responseCode))", withMessage: "Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    popUpError(withTitle: "\(String(describing: error.responseCode))", withMessage: "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    popUpError(withTitle: "\(String(describing: error.responseCode))", withMessage: "Response status code was unacceptable: \(code)")
                }
            case .responseSerializationFailed(let reason):
                popUpError(withTitle: "\(String(describing: error.responseCode))", withMessage: "Response serialization failed because \(reason)")
            }
        } else if let error = error as? URLError {
            popUpError(withTitle: "\(String(describing: error.errorCode)) URLError", withMessage: "URLError occurred: \(error)")
        } else {
            popUpError(withTitle: "Unkown Error", withMessage: "Unknown error occured: \(String(describing: error))")
        }
    }*/
    
    func popUpError(withTitle title: String, withMessage message: String, withAction action: ((UIAlertAction)->())? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: action))
        self.present(alert, animated: true, completion: nil)
    }
    
    func logOut(){
        CurrentUser.logOut()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
    }

}
