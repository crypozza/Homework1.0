//
//  API.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
}


class API {
    
    static let shared = API()
    
    private let db = DB()
    
    private static let usersListUrl = "http://mobi.connectedcar360.net/api/?op=list"
    private static let usersVehicldPoitionsUrl = "http://mobi.connectedcar360.net/api/?op=getlocations&userid={userid}"
    
    func loadUsersList(completion:@escaping (Error?)->Void){
        
        HTTPLoader.load(from: API.usersListUrl) { data, error in
            
            var resultError:Error? = nil
            
            if data != nil{
                
                resultError = self.parseAndStore(users: data!)
                
            }
            
            if let error = error {
                
                print("Error: \(error)")
                resultError = error
            }
            
            completion(resultError)
            
        }
    }
    
    func loadUserVehicles(using id:Int, completion: @escaping (Error?)->Void) {
        
        let addressString = API.usersVehicldPoitionsUrl.replacingOccurrences(of: "{userid}", with: id.description)
        
        HTTPLoader.load(from: addressString) { data, error in
            
            var resultError:Error? = nil
            
            if data != nil{
                
                resultError = self.parseAndStore(vehicles: data!, for: id)
                
            }
            
            if let error = error {
                
                print("Error: \(error)")
                resultError = error
            }
            
            completion(resultError)
        }
        
    }
}

//MARK: - Fetching
extension API {
    
    func fetchUsers()->[User]{
        
        return db.fetchAllUsers()
        
    }
    
    func fetchUser(using id:Int)->User?{
        
        let result = User.fetch(by: id, in: db.context)
        
        return result
    }
    
}


//MARK: - Private funcs

private extension API {
    
    func parseAndStore(vehicles data:Data, for userId:Int)->Error? {
        
        do {
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String,Any>
            
            if let dict = jsonObject, let array = dict["data"] as? Array<Dictionary<String,Any>> {
                store(vehicleArray: array, for: userId)
            }
            
            return nil
            
        } catch {
            
            print("Error: \(error)")
            
            return error
        }
        
    }
    
    func parseAndStore(users data:Data)->Error?{
        
        do {
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String,Any>
            
            if let dict = jsonObject, let array = dict["data"] as? Array<Dictionary<String,Any>> {
                store(dataArray: array)
            }
            
            return nil
            
        } catch {
            
            print("Error: \(error)")
            
            return error
        }
    }
    
}

//MARK: - Parsing
private extension API {
    
    func store(vehicleArray array:Array<Dictionary<String,Any>>, for userId:Int){
        
        let context = db.context
        
        context.performAndWait {
            
            guard let user = User.fetch(by: userId, in: context) else {
                fatalError("Can't find user with id: \(userId)")
            }
            
            for record in array {
                
                guard let vid = record["vehicleid"] as? Int, let lat = record["lat"] as? Double, let lon = record["lon"] as? Double else {
                    print("Can't parse vehicle data for this record")
                    continue
                }
                
                guard let vehicles = user.vehicles.allObjects as? [Vehicle] else {
                    print("Can't find vehicles")
                    continue
                }
                
                guard let vehicle = (vehicles.filter{ $0.vehicleid == vid }).first else {
                    print("Can't find vehicle with id: \(vid)")
                    continue
                }
            
                vehicle.lat = lat
                vehicle.lon = lon
                
                //Store changes
                user.vehicles = NSSet(array: vehicles)
                
            }
            
            db.save(context: context)
        }
        
    }
    
    func store(dataArray array:Array<Dictionary<String,Any>>){
        
        let context = db.context
        
        context.performAndWait {
            
            for record in array {
                
                guard let userid = record["userid"] as? Int else {
                    print("No user id found, escaping...")
                    break
                }
                
                //Update values if record already exists
                var currentUser = User.fetch(by: userid, in: context)
                if currentUser == nil {
                    currentUser = User.insert(using: userid, in: context)
                }
                
                //Now unwrap our current user
                guard let user = currentUser, let jsonOwner = record["owner"] as? Dictionary<String, Any> else {
                    fatalError("Error processing data...")
                }
                
                //Check owner entity
                var currentOwner = user.owner
                if currentOwner == nil {
                    currentOwner = Owner.insert(in: context)
                }
                
                guard let owner = currentOwner else {
                    fatalError("Error processing data...")
                }
                
                //Add to relationship
                user.owner = owner
                
                for keyName in owner.entity.attributesByName.keys {
                    
                    let jsonValue = jsonOwner[keyName]
                    owner.setValue(jsonValue, forKey: keyName)
                }
                
                //Add vehicles
                var currentVehicles = user.vehicles?.allObjects
                if currentVehicles == nil {
                    currentVehicles = []
                }

                
                guard var vehicles = currentVehicles, let jsonVehicles = record["vehicles"] as? Array<Dictionary<String, Any>> else {
                    fatalError("Error processing data...")
                }
                
                //Remove previous data
                vehicles.removeAll()
                
                for jsonVehicle in jsonVehicles {
                    
                    guard let vehicle = Vehicle.insert(in: context) else {
                        fatalError()
                    }
                    
                    for keyName in vehicle.entity.attributesByName.keys {
                        
                        let jsonValue = jsonVehicle[keyName]
                        
                        //Igonring missing keys
                        if jsonValue != nil {
                            vehicle.setValue(jsonValue, forKey: keyName)
                        }
                    }
                    
                    vehicles.append(vehicle)
                    
                }
                
                user.vehicles = NSSet(array: vehicles)
                
            }
            
            db.save(context: context)
        }
    }
    
}
