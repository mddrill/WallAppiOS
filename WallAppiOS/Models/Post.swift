//
//  Post.swift
//  WallAppiOS
//
//  Created by Matthew Drill on 6/17/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation

enum PostFields: String {
    case Id = "id"
    case Author = "author"
    case Text = "text"
    case PostedAt = "posted_at"
}

public struct PostWrapper {
    var posts: [Post] = []
    var count: Int!
    var next: String!
    var previous: String!
}

public struct Post {
    var id: Int!
    var author: String!
    var text: String!
    var postedAt: String!
    
    init?(json: [String: Any]) {
        guard let id = json[PostFields.Id.rawValue] as? Int,
            let author = json[PostFields.Author.rawValue] as? String,
            let text = json[PostFields.Text.rawValue] as? String,
            let dateAsString = json[PostFields.PostedAt.rawValue] as? String
        else {
            return nil
        }
        self.id = id
        self.author = author
        self.text = text
        // First convert the django datetime field to a date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        let unformattedDate = dateFormatter.date(from: dateAsString)
        // Then convert that date object to a string in my custom format
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "eee MMM dd, YYYY"
        self.postedAt = dateFormatter2.string(from: unformattedDate!)
    }
    
    // Checks if post belongs to author
    func belongsTo(author: String) -> Bool {
        return author == self.author
    }
}
