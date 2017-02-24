//
//  Inspection+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Inspection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inspection> {
        return NSFetchRequest<Inspection>(entityName: "Inspection");
    }

    @NSManaged public var date: String?
    @NSManaged public var id: Int32
    @NSManaged public var inspectorId: Int32
    @NSManaged public var address: Address?
    @NSManaged public var results: NSSet?
    @NSManaged public var inspector: Inspector?

}

// MARK: Generated accessors for results
extension Inspection {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Result)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Result)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}
