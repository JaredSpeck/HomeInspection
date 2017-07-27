//
//  Variant+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Variant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Variant> {
        return NSFetchRequest<Variant>(entityName: "Variant")
    }

    @NSManaged public var active: Bool
    @NSManaged public var id: Int32
    @NSManaged public var text: String?
    @NSManaged public var subSection: SubSection?
    @NSManaged public var result: NSSet?
    @NSManaged public var inspectionData: InspectionData?

}

// MARK: Generated accessors for result
extension Variant {

    @objc(addResultObject:)
    @NSManaged public func addToResult(_ value: Result)

    @objc(removeResultObject:)
    @NSManaged public func removeFromResult(_ value: Result)

    @objc(addResult:)
    @NSManaged public func addToResult(_ values: NSSet)

    @objc(removeResult:)
    @NSManaged public func removeFromResult(_ values: NSSet)

}
