//
//  Result.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/29/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class Result {
    
    // Set on initialization (immutable)
    let id: Int
    let inspectionId: Int
    let commentId: Int?
    let variantId: Int?
    
    // Set when used (mutable)
    var note: String
    var severity: Int
    var flags: [Int]?
    var photoPath: String?
    
    // Result initializer
    init(id: Int, inspectionId: Int, commentId: Int?, variantId: Int?) {
        self.id = id
        self.inspectionId = inspectionId
        self.commentId = commentId
        self.variantId = variantId
        
        self.note = ""
        self.flags = nil
        self.photoPath = nil
        self.severity = 1;
    }
}
