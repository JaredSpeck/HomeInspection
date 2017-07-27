//
//  SubSection.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class OldSubSection {

    // Database variables
    var subSectionId: Int!
    var sectionId: Int!
    var subSectionName: String!
    
    // Application variables
    var commentIds: [Int]!
    var variantIds: [Int]!
    var isExpanded: Bool = false
    
    // MARK: - Initializer
    init!(subSectionId: Int!, name: String!, sectionId: Int!) {
        //print("Added subSeciton \(subSectionId!) to section: \(sectionId!)")
        
        
        // Initialize database loaded values
        
        self.subSectionId = subSectionId
        self.subSectionName = name
        self.sectionId = sectionId
        
        
        // Initialize app-specific values

        // Used for accessing id's of comments in this subsection
        self.commentIds = [Int]()
        
        // Used for accessing id's of types in this subsection
        self.variantIds = [Int]()
        
        // Used to tell if a subsection has been expanded to view more than top X comments
        self.isExpanded = false
        
        loadSampleVariants()
    }
    
    // loads variant ids with 2 dummy values for testing. Remove once database has variant entries
    func loadSampleVariants() {
         variantIds.append(0)
    }

}
