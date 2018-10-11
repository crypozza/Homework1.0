//
//  Owner+CoreDataClass.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Owner)
public class Owner: NSManagedObject {
    
    static let entityName = "Owner"
}

extension Owner {
    
    class func insert(in context:NSManagedObjectContext)->Owner? {
        
        guard let ownerEntityDescripton = NSEntityDescription.entity(forEntityName: Owner.entityName, in: context) else {
            fatalError("Failed to create new owner entity descriptor")
        }
        let owner = NSManagedObject(entity: ownerEntityDescripton, insertInto: context) as! Owner
        
        return owner
    }
}
