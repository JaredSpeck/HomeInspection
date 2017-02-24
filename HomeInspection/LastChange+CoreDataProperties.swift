//
//  LastChange+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension LastChange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastChange> {
        return NSFetchRequest<LastChange>(entityName: "LastChange");
    }

    @NSManaged public var commentTime: String?
    @NSManaged public var sectionTime: String?
    @NSManaged public var subSectionTime: String?

}
