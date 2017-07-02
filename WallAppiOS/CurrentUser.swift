//
//  CurrentUser.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/2/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//
import Foundation

public class CurrentUser {
    
    static var token: String!
    static var username: String!
    
    static func loggedIn() -> Bool {
        return token != nil
    }
    
    static func logOut() {
        token = nil
        username = nil
    }
}

