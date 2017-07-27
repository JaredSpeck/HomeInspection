//
//  Section+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Section {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: "Section")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var subSections: NSSet?
    @NSManaged public var inspectionData: InspectionData?

}

// MARK: Generated accessors for subSections
extension Section {

    @objc(addSubSectionsObject:)
    @NSManaged public func addToSubSections(_ value: SubSection)

    @objc(removeSubSectionsObject:)
    @NSManaged public func removeFromSubSections(_ value: SubSection)

    @objc(addSubSections:)
    @NSManaged public func addToSubSections(_ values: NSSet)

    @objc(removeSubSections:)
    @NSManaged public func removeFromSubSections(_ values: NSSet)

}
