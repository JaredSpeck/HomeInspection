//
//  InspectionData+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension InspectionData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionData> {
        return NSFetchRequest<InspectionData>(entityName: "InspectionData")
    }

    @NSManaged public var id: Int32
    @NSManaged public var commentModTime: String?
    @NSManaged public var subSectionModTime: String?
    @NSManaged public var sectionModTime: String?
    @NSManaged public var sections: NSSet?
    @NSManaged public var subsections: NSSet?
    @NSManaged public var comments: NSSet?
    @NSManaged public var variants: NSSet?

}

// MARK: Generated accessors for sections
extension InspectionData {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Section)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Section)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}

// MARK: Generated accessors for subsections
extension InspectionData {

    @objc(addSubsectionsObject:)
    @NSManaged public func addToSubsections(_ value: SubSection)

    @objc(removeSubsectionsObject:)
    @NSManaged public func removeFromSubsections(_ value: SubSection)

    @objc(addSubsections:)
    @NSManaged public func addToSubsections(_ values: NSSet)

    @objc(removeSubsections:)
    @NSManaged public func removeFromSubsections(_ values: NSSet)

}

// MARK: Generated accessors for comments
extension InspectionData {

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
extension InspectionData {

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: Variant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: Variant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSSet)

}
