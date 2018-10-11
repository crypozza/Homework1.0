//
//  Vehicles+CoreDataClass.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Vehicle)
public class Vehicle: NSManagedObject {
    
    static let entityName:String = "Vehicle"

}

extension Vehicle {
    
    class func insert(in context:NSManagedObjectContext)->Vehicle? {
        
        guard let entityDescripton = NSEntityDescription.entity(forEntityName: Vehicle.entityName, in: context) else {
            fatalError("Failed to create new owner entity descriptor")
        }
        let object = NSManagedObject(entity: entityDescripton, insertInto: context) as! Vehicle
        return object
    }
}
