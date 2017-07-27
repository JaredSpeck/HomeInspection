//
//  Result+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result")
    }

    @NSManaged public var id: Int32
    @NSManaged public var isActive: Bool
    @NSManaged public var note: String?
    @NSManaged public var tableLocation: String? //"inspId,section,subsection,row"
    @NSManaged public var photo: NSData?
    @NSManaged public var severity: Int32
    @NSManaged public var comment: Comment?
    @NSManaged public var extraFlags: NSSet?
    @NSManaged public var inspection: Inspection?
    @NSManaged public var variant: Variant?

}

// MARK: Generated accessors for extraFlags
extension Result {

    @objc(addExtraFlagsObject:)
    @NSManaged public func addToExtraFlags(_ value: Flag)

    @objc(removeExtraFlagsObject:)
    @NSManaged public func removeFromExtraFlags(_ value: Flag)

    @objc(addExtraFlags:)
    @NSManaged public func addToExtraFlags(_ values: NSSet)

    @objc(removeExtraFlags:)
    @NSManaged public func removeFromExtraFlags(_ values: NSSet)

}
