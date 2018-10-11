//
//  HTTPLoader.swift
//  Homework1.0
//
//  Created by Alexey Volkov on 08/10/2018.
//  Copyright © 2018 Alexey Volkov. All rights reserved.
//

import Foundation

enum HTTPLoaderError:Error{
    case wrongURL
}

class HTTPLoader{
    
    class func load(from url:String, completion: @escaping (Data?, Error?)->Void) {
        
        guard let remoteUrl = URL(string: url) else {
            
            let error = HTTPLoaderError.wrongURL
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: remoteUrl) { data, response, error in
            
            
            completion(data, error)
            
        }
        
        task.resume()
        
    }
    
}
