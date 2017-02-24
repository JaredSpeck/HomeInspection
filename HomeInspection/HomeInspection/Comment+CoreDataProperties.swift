//
//  Comment+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment");
    }

    @NSManaged public var id: Int32
    @NSManaged public var text: String?
    @NSManaged public var rank: Int16
    @NSManaged public var active: Bool
    @NSManaged public var result: Result?
    @NSManaged public var subSection: SubSection?
    @NSManaged public var defaultFlags: NSSet?

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
