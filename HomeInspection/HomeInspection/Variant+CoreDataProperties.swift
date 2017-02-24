//
//  Variant+CoreDataProperties.swift
//  HomeInspection
//
//  Created by Jared Speck on 2/23/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import Foundation
import CoreData


extension Variant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Variant> {
        return NSFetchRequest<Variant>(entityName: "Variant");
    }

    @NSManaged public var id: Int32
    @NSManaged public var text: String?
    @NSManaged public var active: Bool
    @NSManaged public var result: Result?
    @NSManaged public var subSection: SubSection?

}
