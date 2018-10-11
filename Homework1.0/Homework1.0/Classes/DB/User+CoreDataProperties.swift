//
//  User+CoreDataProperties.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @NSManaged public var userid: Int32
    @NSManaged public var owner: Owner!
    @NSManaged public var vehicles: NSSet!

}
