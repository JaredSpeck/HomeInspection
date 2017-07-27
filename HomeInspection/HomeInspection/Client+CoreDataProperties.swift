//
//  Client+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var first: String?
    @NSManaged public var id: Int32
    @NSManaged public var last: String?
    @NSManaged public var phone: String?
    @NSManaged public var addresses: NSSet?
    @NSManaged public var inspections: NSSet?

}

// MARK: Generated accessors for addresses
extension Client {

    @objc(addAddressesObject:)
    @NSManaged public func addToAddresses(_ value: Address)

    @objc(removeAddressesObject:)
    @NSManaged public func removeFromAddresses(_ value: Address)

    @objc(addAddresses:)
    @NSManaged public func addToAddresses(_ values: NSSet)

    @objc(removeAddresses:)
    @NSManaged public func removeFromAddresses(_ values: NSSet)

}

// MARK: Generated accessors for inspections
extension Client {

    @objc(addInspectionsObject:)
    @NSManaged public func addToInspections(_ value: Inspection)

    @objc(removeInspectionsObject:)
    @NSManaged public func removeFromInspections(_ value: Inspection)

    @objc(addInspections:)
    @NSManaged public func addToInspections(_ values: NSSet)

    @objc(removeInspections:)
    @NSManaged public func removeFromInspections(_ values: NSSet)

}
