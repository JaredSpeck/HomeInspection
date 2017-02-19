//
//  Type.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/18/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class Variant {
    
    //MARK: Properties
    private(set) var variantId: Int!
    private(set) var subSectionId: Int!
    private(set) var name: String!
    private(set) var active: Bool! = false
    
    var resultId: Int?
    
    //MARK: Initialization
    init!(variantId: Int!, subSectionId: Int!, name: String!, active: Bool? = false) {
        
        //print("Adding comment -> Id: \(commentId!), Text: \(commentText!)")
        
        // Initialize database loaded values
        self.variantId = variantId
        self.subSectionId = subSectionId
        self.name = name
        self.active = active
        
        // Initialize app-specific values
        self.resultId = nil;
    }

}
