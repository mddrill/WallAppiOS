//
//  Token.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 7/2/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation

struct Token {
    var value: String!
    
    init?(json: [String: Any]) {
        guard let value = json["token"] as? String else{
            return nil
        }
        self.value = value
    }
}
