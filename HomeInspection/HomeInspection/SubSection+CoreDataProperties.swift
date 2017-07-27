//
//  SubSection+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension SubSection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubSection> {
        return NSFetchRequest<SubSection>(entityName: "SubSection")
    }

    @NSManaged public var id: Int32
    @NSManaged public var isExpanded: Bool
    @NSManaged public var name: String?
    @NSManaged public var comments: NSSet?
    @NSManaged public var section: Section?
    @NSManaged public var variants: NSSet?
    @NSManaged public var inspectionData: InspectionData?

}

// MARK: Generated accessors for comments
extension SubSection {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}

// MARK: Generated accessors for variants
extension SubSection {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: Variant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: Variant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSSet)

}
