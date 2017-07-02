//
//  AppDelegate.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/23/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit
import Mockingjay


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        
        if ProcessInfo.processInfo.arguments.contains("StubNetworkResponses") {
            var urlsToExclude: [String] = []
            for (url, errorCode) in ProcessInfo.processInfo.environment {
                if let code = Int(errorCode) {
                    print(url)
                    print(code)
                    urlsToExclude += [url]
                    let error = NSError(domain: "\(errorCode) Error", code: code, userInfo: nil)
                    MockingjayProtocol.addStub(matcher: uri(url), builder: failure(error))
                }
            }
            stubEndpointsIntoFixtures(exclude: urlsToExclude)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

fileprivate func stubEndpointsIntoFixtures(exclude urlsToExclude: [String]) {
    var path = Bundle.main.path(forResource: "GetPosts", ofType: "json")
    var data = NSData(contentsOfFile: path!)!
    if !urlsToExclude.contains(PostServiceClient.endpointForPost()){
        MockingjayProtocol.addStub(matcher: http(.get, uri: PostServiceClient.endpointForPost()), builder: jsonData(data as Data))
    }
    
    path =  Bundle.main.path(forResource: "CreatePost", ofType: "json")
    data = NSData(contentsOfFile: path!)!
    if !urlsToExclude.contains(PostServiceClient.endpointForPost()){
        MockingjayProtocol.addStub(matcher: http(.post, uri: PostServiceClient.endpointForPost()), builder: jsonData(data as Data, status: 201))
    }
    let samplePostIds = [1, 3, 17, 42, 3190]
    
    path = Bundle.main.path(forResource: "EditPost", ofType: "json")
    data = NSData(contentsOfFile: path!)!
    for id in samplePostIds {
        if !urlsToExclude.contains(PostServiceClient.endpointForPost(withId: id)){
            MockingjayProtocol.addStub(matcher: http(.patch, uri: PostServiceClient.endpointForPost(withId: id)), builder: jsonData(data as Data))
        }
    }
    
    
    path = Bundle.main.path(forResource: "DeletePost", ofType: "json")
    data = NSData(contentsOfFile: path!)!
    for id in samplePostIds {
        if !urlsToExclude.contains(PostServiceClient.endpointForPost(withId: id)){
            MockingjayProtocol.addStub(matcher: http(.delete, uri: PostServiceClient.endpointForPost(withId: id)), builder: jsonData(data as Data))
        }
    }
    
    path = Bundle.main.path(forResource: "RegisterUser", ofType: "json")
    data = NSData(contentsOfFile: path!)!
    if !urlsToExclude.contains(AccountsServiceClient.endpointForAccounts()){
        MockingjayProtocol.addStub(matcher: uri(AccountsServiceClient.endpointForAccounts()), builder: jsonData(data as Data, status: 201))
    }
    
    path = Bundle.main.path(forResource: "Login", ofType: "json")
    data = NSData(contentsOfFile: path!)!
    if !urlsToExclude.contains(AccountsServiceClient.endpointForLogin()){
        MockingjayProtocol.addStub(matcher: uri(AccountsServiceClient.endpointForLogin()), builder: jsonData(data as Data, status: 200))
    }
}

