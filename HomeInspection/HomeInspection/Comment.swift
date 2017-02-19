//
//  Comment.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class Comment {
    
    //MARK: Properties
    private(set) var commentId: Int!
    private(set) var subSectionId: Int!
    private(set) var defaultFlags: [Int8]!
    private(set) var commentText: String!
    private(set) var rank: Int!
    private(set) var active: Bool! = false
    
    var resultId: Int?
    
    //MARK: Initialization
    init!(commentId: Int!, subSectionId: Int!, rank: Int!, commentText: String!, defaultFlags:[Int8]!, active: Bool? = false) {
 
        //print("Adding comment -> Id: \(commentId!), Text: \(commentText!)")
        
        // Initialize database loaded values
        self.commentId = commentId
        self.subSectionId = subSectionId
        self.defaultFlags = defaultFlags
        self.commentText = commentText
        self.rank = rank
        self.active = active
        
        // Initialize app-specific values
        self.resultId = nil;
    }
}
