//
//  APIRequest.swift
//  ExpressionFramework
//
//  Created by Matt Harding on 08/11/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import Foundation

class APIRequest { // TODO this class is NOT production ready. It is only for development use
    
    static func getListings(completion: @escaping (Result<[Listing], Void>) -> Void) {
        URLSession.expression.dataTask(with: ExpressionConfig.url.url!) { data, response, error in
            guard
                let arrayOfListingDictionaries = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: AnyObject]]
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
        }.resume()
    }
    
    static func getAdverts(completion: @escaping (Result<[Advert], Void>) -> Void) {
        URLSession.expression.dataTask(with: ExpressionConfig.url.url!) { data, response, error in
            guard
                let arrayOfListingDictionaries = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(()))
                    }
                    return
            }
            let adverts: [Advert] = arrayOfListingDictionaries.flatMap{ Advert(jsonDictionary: $0) }
            
            DispatchQueue.main.async {
                completion(.success(adverts))
            }
            }.resume()
    }
}

