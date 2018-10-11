//
//  Vehicles+CoreDataProperties.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var vehicleid: Int32
    @NSManaged public var make: String
    @NSManaged public var model: String
    @NSManaged public var year: String
    @NSManaged public var color: String
    @NSManaged public var vin: String
    @NSManaged public var foto: String
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var user: User

}
