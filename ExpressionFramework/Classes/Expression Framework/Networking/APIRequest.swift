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
    
    static func getPresenceItems(completion: @escaping (Result<[PresenceInfo], Void>) -> Void) {
        URLSession.expression.dataTask(with: ExpressionConfig.url.url!) { data, response, error in
            guard
                let arrayOfListingDictionaries = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: AnyObject]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(()))
                    }
                    return
            }
            let presenceItems: [ExpressionRepresentable] = arrayOfListingDictionaries.flatMap{ PresenceItem(jsonDictionary: $0) }
            var indexToInsert = 0
            let presenceItemsWithIndexPaths: [PresenceInfo] = presenceItems.map({
                indexToInsert += 4  // TODO these indexes should be coming from the server
                return PresenceInfo(indexPath: IndexPath(row: indexToInsert, section: 0), expressionContainer: $0)
            })
            DispatchQueue.main.async {
                completion(.success(presenceItemsWithIndexPaths))
            }
            }.resume()
    }
}

