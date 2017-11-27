//
//  ExpressionAPI.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 08/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

class ExpressionAPI {
    
    let environmentUrl = "http://matts-mbp.ad1.tm-gnet.com:8000/" // TODO inject this into the class
    
    func getListings(completion: @escaping (Result<[Listing], Void>) -> Void) {
        
        let request = APIRequest(endPoint: "1.json", environmentUrl: environmentUrl, httpMethod: "GET")
        request.fire() { jsonObject, error in
    
            guard
                let arrayOfListingDictionaries = jsonObject as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(()))
                    }
                    return
            }
            
            let listings: [Listing] = arrayOfListingDictionaries.flatMap{ Listing(jsonDictionary: $0) }
            
            DispatchQueue.main.async {
                completion(.success(listings))
            }
        }
    }
}
