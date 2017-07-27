//
//  AppValues+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension AppValues {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppValues> {
        return NSFetchRequest<AppValues>(entityName: "AppValues")
    }

    @NSManaged public var commentModTime: String?
    @NSManaged public var sectionModTime: String?
    @NSManaged public var subSectionModTime: String?
    @NSManaged public var tempInspectionId: Int32
    @NSManaged public var tempResultId: Int32

}
