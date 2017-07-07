//
//  Result+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result");
    }
    @NSManaged public var isActive: Bool
    @NSManaged public var id: Int32
    @NSManaged public var note: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var severity: Int32
    @NSManaged public var inspection: Inspection?
    @NSManaged public var comment: Comment?
    @NSManaged public var variant: Variant?
    @NSManaged public var flags: NSSet?

}

// MARK: Generated accessors for flags
extension Result {

    @objc(addFlagsObject:)
    @NSManaged public func addToFlags(_ value: Flag)

    @objc(removeFlagsObject:)
    @NSManaged public func removeFromFlags(_ value: Flag)

    @objc(addFlags:)
    @NSManaged public func addToFlags(_ values: NSSet)

    @objc(removeFlags:)
    @NSManaged public func removeFromFlags(_ values: NSSet)

}
