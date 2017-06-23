//
//  Account.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation

// This class was for extra features which I did not have time to implement.

enum AccountFields:  String {
    case Username = "username"
    case Email = "email"
}

struct Account {
    var username: String!
    var email: String!
    
    init(json: [String: Any]) {
        self.username = json[AccountFields.Username.rawValue] as! String
        self.email = json[AccountFields.Username.rawValue] as! String
    }
}
