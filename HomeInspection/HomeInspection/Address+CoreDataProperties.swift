//
//  Address+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address");
    }

    @NSManaged public var id: Int32
    @NSManaged public var city: String?
    @NSManaged public var photoPath: String?
    @NSManaged public var squareFootage: Int32
    @NSManaged public var street: String?
    @NSManaged public var zip: String?
    @NSManaged public var inspection: Inspection?
    @NSManaged public var client: Client?

}
