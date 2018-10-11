//
//  User+CoreDataClass.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    static let entityName:String = "User"

}

extension User {
    
    class func fetchAll(in context:NSManagedObjectContext)->[User]? {
        
        do {
            let users = try context.fetch(User.fetchRequest()) as? [User]
            return users
        } catch {
            fatalError("Failed to perform fetch request: \(error)")
        }
    }
    
    class func fetch(by id:Int, in context:NSManagedObjectContext)->User? {
        
        let predicate = NSPredicate(format: "userid=%@", NSNumber(value: id))
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: User.entityName)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request) as? [User]
            return users?.first
            
        } catch {
            fatalError("Failed to perform fetch request: \(error)")
        }
        
        return nil
    }
        
    class func insert(using id:Int, in context:NSManagedObjectContext)->User? {
        
        guard let userEntityDescripton = NSEntityDescription.entity(forEntityName: User.entityName, in: context) else {
            fatalError("Failed to create new user entity descriptor")
        }
        let user = NSManagedObject(entity: userEntityDescripton, insertInto: context) as! User
        user.userid = Int32(id)
        
        return user
    }
    
}
