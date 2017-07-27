//
//  Address+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var city: String?
    @NSManaged public var id: Int32
    @NSManaged public var squareFootage: Int32
    @NSManaged public var street: String?
    @NSManaged public var zip: String?
    @NSManaged public var client: Client?
    @NSManaged public var inspections: NSSet?

}

// MARK: Generated accessors for inspections
extension Address {

    @objc(addInspectionsObject:)
    @NSManaged public func addToInspections(_ value: Inspection)

    @objc(removeInspectionsObject:)
    @NSManaged public func removeFromInspections(_ value: Inspection)

    @objc(addInspections:)
    @NSManaged public func addToInspections(_ values: NSSet)

    @objc(removeInspections:)
    @NSManaged public func removeFromInspections(_ values: NSSet)

}
