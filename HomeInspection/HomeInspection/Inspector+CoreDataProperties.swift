//
//  Inspector+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Inspector {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inspector> {
        return NSFetchRequest<Inspector>(entityName: "Inspector");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var inspections: NSSet?

}

// MARK: Generated accessors for inspections
extension Inspector {

    @objc(addInspectionsObject:)
    @NSManaged public func addToInspections(_ value: Inspection)

    @objc(removeInspectionsObject:)
    @NSManaged public func removeFromInspections(_ value: Inspection)

    @objc(addInspections:)
    @NSManaged public func addToInspections(_ values: NSSet)

    @objc(removeInspections:)
    @NSManaged public func removeFromInspections(_ values: NSSet)

}
