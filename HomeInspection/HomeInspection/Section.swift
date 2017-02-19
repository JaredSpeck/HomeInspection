//
//  Section.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/2/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class Section {
    
    
    
    // Properties
    var sectionId: Int!;
    var sectionName: String!;
    
    var subSectionIds: [Int]!
    
    init(id: Int!, name: String!) {
        
        //print("Addded section \(id!)")
        
        self.sectionId = id
        self.sectionName = name
        self.subSectionIds = [Int]()
    }
    
}
