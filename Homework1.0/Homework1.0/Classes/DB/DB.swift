//
//  DB.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import Foundation
import CoreData

class DB {
    
    private lazy var persistantContainer:NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DBModel")
        container.loadPersistentStores { description, error in
            
            if let error = error {
                
                fatalError("FatalError: \(error)")
            }
            
        }
        
        return container
        
    }()
    
    
    func save(context: NSManagedObjectContext){
        
        if context.hasChanges == true {
            do {
                try context.save()
            } catch {
                
                print("Warning: error saving context: \(error)")
            }
        }
        
    }
    
    var context:NSManagedObjectContext {
        get {
            
            if Thread.current.isMainThread == true {
                return persistantContainer.viewContext
            }
            
            let ctx = persistantContainer.newBackgroundContext()
            ctx.automaticallyMergesChangesFromParent = true
            
            return ctx
        }
    }
}

//MARK: - Store data
extension DB {
    
    func fetchAllUsers()->[User]{
        
        var returnUsers:[User] = []
        self.context.performAndWait {
            
            let request = User.fetchRequest()
            
            do {
                let users = try self.context.fetch(request) as! [User]
            
                returnUsers.append(contentsOf: users)
                
            } catch {
                fatalError("Failed to request users...")
            }
            
        }
        
        return returnUsers
        
    }
    
}
