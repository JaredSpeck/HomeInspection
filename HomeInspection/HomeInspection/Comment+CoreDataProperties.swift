//
//  Comment+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var active: Bool
    @NSManaged public var id: Int32
    @NSManaged public var rank: Int16
    @NSManaged public var text: String?
    @NSManaged public var defaultFlags: NSSet?
    @NSManaged public var subSection: SubSection?
    @NSManaged public var results: NSSet?
    @NSManaged public var inspectionData: InspectionData?

}

// MARK: Generated accessors for defaultFlags
extension Comment {

    @objc(addDefaultFlagsObject:)
    @NSManaged public func addToDefaultFlags(_ value: Flag)

    @objc(removeDefaultFlagsObject:)
    @NSManaged public func removeFromDefaultFlags(_ value: Flag)

    @objc(addDefaultFlags:)
    @NSManaged public func addToDefaultFlags(_ values: NSSet)

    @objc(removeDefaultFlags:)
    @NSManaged public func removeFromDefaultFlags(_ values: NSSet)

}

// MARK: Generated accessors for result
extension Comment {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Result)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Result)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}
