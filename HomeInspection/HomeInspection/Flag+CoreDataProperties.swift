//
//  Flag+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Flag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Flag> {
        return NSFetchRequest<Flag>(entityName: "Flag");
    }

    @NSManaged public var id: Int32
    @NSManaged public var text: NSObject?
    @NSManaged public var result: NSSet?
    @NSManaged public var comments: NSSet?

}

// MARK: Generated accessors for result
extension Flag {

    @objc(addResultObject:)
    @NSManaged public func addToResult(_ value: Result)

    @objc(removeResultObject:)
    @NSManaged public func removeFromResult(_ value: Result)

    @objc(addResult:)
    @NSManaged public func addToResult(_ values: NSSet)

    @objc(removeResult:)
    @NSManaged public func removeFromResult(_ values: NSSet)

}

// MARK: Generated accessors for comments
extension Flag {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
